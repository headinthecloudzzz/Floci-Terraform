terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "floci_endpoint" {
  type    = string
  default = "http://localhost:4566"
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3 = var.floci_endpoint
  }
}

resource "aws_s3_bucket" "learning" {
  bucket = "my-first-bucket"

  # lifecycle {
  #   prevent_destroy = true
  # }
}

output "bucket_arn" {
  value = aws_s3_bucket.learning.arn
}

output "bucket_name" {
  value = aws_s3_bucket.learning.bucket
}
