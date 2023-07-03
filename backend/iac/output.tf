output "lambda_urls" {
  description = "The URLs to invoke the Lambda functions over the internet"
  value       = { for k, v in aws_lambda_function.lambdas : k => "https://${k}.lambda-url.${data.aws_region.current.name}.on.aws" }
}
