data "aws_iam_policy_document" "sagemaker_exec" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_exec" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sagemaker_invoke" {
  statement {
    actions   = ["sagemaker:InvokeEndpoint"]
    resources = [aws_sagemaker_endpoint.main.arn]
  }
}

resource "aws_iam_role" "sagemaker_exec" {
  name               = "sagemaker_exec"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_exec.json
}

resource "aws_iam_role_policy_attachment" "sagemaker_policies" {
  for_each   = local.sagemaker.policies
  role       = aws_iam_role.sagemaker_exec.name
  policy_arn = each.key
}

resource "aws_iam_role_policy" "sagemaker_invoke" {
  name   = "sagemaker_invoke"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.sagemaker_invoke.json
}

resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policies" {
  for_each   = local.lambda.policies
  role       = aws_iam_role.lambda_exec.name
  policy_arn = each.key
}
