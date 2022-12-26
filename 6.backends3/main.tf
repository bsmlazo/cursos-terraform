terraform {
    # aca se define el backend que se utilizará
  backend "s3" {
    bucket = local.bucket
    key    = "servidor/terraform.tfstate"
    region = local.region

    dynamodb_table = local.dynamodb_table
    encrypt        = true
  }
}

locals {
  region = "us-east-1"
  bucket = "tf-infra-como-codigo-bsm"
  dynamodb_table = "tf-infra-como-codigo-locks-bsm"
}

provider "aws" {
  region = local.region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.bucket

  lifecycle {
    # dejamos esta propiedad en true para proteger el archivo de estado
    # y no eliminarlo nunca, eso sería fatal
    prevent_destroy = true
  }
  
  # habilitamos el versionamiento en el bucket
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = local.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_instance" "servidor" {
  ami           = "ami-0aef57767f5404a3c"
  instance_type = "t2.micro"
}