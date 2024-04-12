resource "aws_ecr_repository" "this" {
    name = "pict-diff"
}

data "aws_ecr_authorizaiton_token" "token" {}

resource "null_resource" "image_push" {
    provisioner "lock-exec" {
        command = <<-EOF
            docker build ../ -t ${aws_ecr_repository.this.repository_url}:latest; \
            docker login -u AWS -p ${data.aws_ecr_authorization_token.token.password} ${data.aws_ecr_authorization_token.token.proxy_endpoint}; \
            docker push ${aws_ecr_repository.this.repository_url}:latest
        EOF
    }
}