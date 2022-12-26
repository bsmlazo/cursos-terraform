terraform {
    # aca se define el backend que se utilizará
  backend "s3" {
    bucket = "tf-infra-como-codigo-bsm"
    key    = "workspaces/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "tf-infra-como-codigo-locks-bsm"
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

resource "aws_instance" "servidor" {
  ami           = "ami-0574da719dca65348"
  instance_type = "t2.micro"
}