resource "aws_sagemaker_model" "main" {
  name               = local.model.name
  execution_role_arn = aws_iam_role.sagemaker_exec.arn

  primary_container {
    image          = local.model.image
    model_data_url = "s3://${aws_s3_bucket.main.bucket}/${aws_s3_object.model_file.key}"
  }
}

resource "aws_sagemaker_endpoint_configuration" "main" {
  name = "${local.base_name}-endpoint-config"

  production_variants {
    variant_name           = local.model.variant.variant_name
    model_name             = aws_sagemaker_model.main.name
    initial_instance_count = local.model.variant.instance_count
    instance_type          = local.model.variant.instance_type
  }
}

resource "aws_sagemaker_endpoint" "main" {
  name                 = "${local.base_name}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.main.name
}
