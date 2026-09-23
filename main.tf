# 1. Cria um arquivo ZIP simples em Python para a Lambda executar
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source {
    content  = <<EOF
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Ola do Terraform na AWS Sandbox!'
    }
EOF
    filename = "lambda_function.py"
  }
}

# 2. Cria uma IAM Role básica para a Lambda ter permissão de execução
resource "aws_iam_role" "lambda_role" {
  name = "terraform_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Anexa a política básica de logs para a role da Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 3. Cria o recurso da AWS Lambda
resource "aws_lambda_function" "minha_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "primeira-lambda-terraform"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# 4. Exibe o nome da Lambda criada no final
output "lambda_name" {
  value = aws_lambda_function.minha_lambda.function_name
}