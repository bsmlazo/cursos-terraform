terraform {
  cloud {
    organization = "bsmlazo"

    workspaces {
      name = "tf-infra-como-codigo"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "servidor-tf" {
  ami = "ami-0574da719dca65348"
  instance_type = "t2.micro"
}