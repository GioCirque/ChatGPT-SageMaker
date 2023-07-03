data "archive_file" "lambda" {
  type        = "zip"                                       # Zip the lambda code
  output_path = "${path.module}/../lambdas/lambda_chat.zip" # Path to the lambda zip file

  source {
    content  = file("${path.module}/../lambdas/chat/function.py") # Lambda code
    filename = "function.py"                                      # Lambda code filename
  }
  source {
    content  = file("${path.module}/../lambdas/chat/requirements.txt") # Lambda code
    filename = "requirements.txt"                                      # Lambda code filename
  }
}

resource "aws_lambda_function" "lambdas" {
  for_each = fileset("./backend/lambdas/", "lambda_*.zip") # Iterate over all lambda zip files

  runtime          = "python3.8"                                         # Lambda runtime for Python 3.8
  filename         = "${path.module}/../lambdas/${each.value}"                   # Path to the lambda zip file
  function_name    = substr(each.value, 7, length(each.value) - 4)       # Skip 'lambda_' and remove '.zip' from the filename
  handler          = substr(each.value, 7, length(each.value) - 4)       # Skip 'lambda_' and remove '.zip' from the filename
  source_code_hash = filebase64sha256("${path.module}/../lambdas/${each.value}") # Hash of the lambda zip file
  role             = aws_iam_role.lambda_exec.arn                        # IAM role for the lambda

  environment {
    variables = {
      BUCKET        = aws_s3_bucket.main.bucket        # S3 bucket name
      ENDPOINT_NAME = aws_sagemaker_endpoint.main.name # Endpoint name for SageMaker invocation
    }
  }
}
