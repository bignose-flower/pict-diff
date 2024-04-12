# API Gateway
resource "aws_api_gateway_rest_api" "container_image" {
    name = local.apigateway_name
    body = data.template_file.apigateway_body.rendered
}

data "template_file" "apigateway_body" {
    template = file("./apigateway_body.yaml")

    vars = {
        title = local.apigateway_name
        aws_account = data.aws_caller_identity.self.account_id
        aws_region_name = data.aws_region.current.name
        lambda_pict_diff_function_name = aws_lambda_function.this.function_name
    }
}

# API Gatewayのステージについて

resource "aws_api_gateway_stage" "prod" {
    stage_name = "prod"
    rest_api_id = aws_api_gateway_rest_api.container_image.id
    deployment_id = aws_api_gateway_deployment.for_prod.id

    # キャッシュ設定
    cache_cluster_enabled = false
    # X-Rayトーレスの設定
    # リクエストに関するデータを収集するサービス
    xray_tracing_enabled = false
}

resource "aws_api_gateway_deployment" "for_prod" {
    rest_api_id = aws_api_gateway_rest_api.container_image.id
    triggers = {
        redeployment = sha1(jsonencode([
            data.template_file.apigateway_body.rendered
        ]))
    }

    lifecycle {
      # 既存デプロイがある場合は先に削除してから新規作成を行う
      create_before_destroy = true
    }
}