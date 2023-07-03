locals {
  base_name = "chat-gpt"

  model = {
    name            = "falcon-40b-instruct"
    download_url    = "https://huggingface.co/tiiuae/falcon-40b-instruct/resolve/main/pytorch_model.bin"
    local_temp_path = "/tmp/falcon-40b-instruct.bin"
    variant = {
      variant_name   = "variant-1"
      instance_type  = "ml.m4.xlarge"
      instance_count = 1
    }
    image = "763104351884.dkr.ecr.us-west-2.amazonaws.com/huggingface-pytorch-inference:1.7.1-cpu"
  }

  sagemaker = {
    policies = toset([
      "arn:aws:iam::aws:policy/AmazonS3FullAccess",
      "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess",
    ])
  }

  lambda = {
    policies = toset([
      "arn:aws:iam::aws:policy/AmazonS3FullAccess",
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    ])
    root = "${path.module}../lambdas"
  }
}
