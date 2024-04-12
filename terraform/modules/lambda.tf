# Lambda Function
resource "aws_lambda_function" "this" {
    depends_on = [
        aws_cloudwatch_log_group.lambda_pict_diff,
        null_resource.image_push
    ]

    function_name = local.lambda_pict_diff_function_name
    package_type = "Image"
    image_uri = "${aws_ecr_repository.this.repository_url}:latest"
    role = aws_iam_role.lambda_pict_diff.arn
    # バージョンを払出
    # 払出だしたバージョンはaliasでエイリアスを割り付ける
    publish = true

    memory_size = 128
    timeout = 28

    lifecycle {
        ignore_changes = [
            image_uri, last_modified
        ]
    }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_pict_diff" {
    name = local.lambda_pict_diff_iam_role_name
    assume_role_policy = data.aws_iam_policy_document.lambda_pict_diff_assume.json
}

data "aws_iam_policy_document" "lambda_pict_diff_assume" {
    statement {
        effect = "Allow"

        actions = [
            "sts:AssumeRole"
        ]

        principals {
            type = "Service"
            identifiers = [
                "lambda.amazonaws.com"
            ]
        }
    }
}

resource "aws_iam_role_policy_attachment" "lambda_pict_diff" {
    role = aws_iam_role.lambda_pict_diff.name
    policy_arn = aws_iam_policy.lambda_pict_diff_custom.arn
}

resource "aws_iam_policy" "lambda_pict_diff_custom" {
    name = local.lambda_pict_diff_iam_policy_name
    policy = data.aws_iam_policy_document.lambda_pict_diff_custom.json
}

data "aws_iam_policy_document" "lambda_pict_diff_custom" {
    statement {
        effect = "Allow"

        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
        ]

        resources = [
            "*"
        ]
    }
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "lambda_pict_diff" {
    name = "/aws/lambda/${local.lambda_pict_diff_function_name}"
    retention_in_days = 3
}

# Lambda Alias
# 更新可能な関数のバージョンへのポインタ
# バージョン発行すると、修飾ARNで管理される
# 最新版のLambda関数はバージョンのサフィックスが付与されない
# ソースコードを修正する場合は$LATESTの方を修正して、必要に応じてバージョン発行する必要があります。
# $LATESTの方を本番環境とすると、誤った変更を行ったら大変
# バージョン発行後にエイリアスを作成して、本番環境のバージョンを紐づけする必要あり
# aws_lambda_alias.pict_diff_prod自体のバージョンもこの後のCI/CDで変わってしまうので、ignore_changesするようにする
resource "aws_lambda_alias" "pict_diff_prod" {
    name = "Prod"
    function_name = aws_lambda_function.this.arn
    function_version = aws_lambda_function.this.version

    lifecycle {
      ignore_changes = [ function_version ]
    }
}

# Lambda Permission
# 他のAWSのサービスと紐づける場合には、qualifierにprodのaliasで指定するようにする
resource "aws_lambda_permission" "allow_apigateway" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.this.function_name
    principal = "apigateway.amazonaws.com"
    qualifier = aws_lambda_alias.pict_diff_prod.name
}