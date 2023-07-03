resource "aws_s3_bucket" "main" {
  bucket = "${local.base_name}-main"
}

resource "aws_s3_object" "model_file" {
  depends_on = [null_resource.download_model]

  bucket = aws_s3_bucket.main.bucket
  key    = local.model.name
  source = local.model.local_temp_path
  acl    = "private"
}

resource "null_resource" "download_model" {
  provisioner "local-exec" {
    command = "wget ${local.model.download_url} -O ${local.model.local_temp_path}"
  }
}
