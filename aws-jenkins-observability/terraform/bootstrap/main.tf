variable "environment" {
  description = "The deployment environment (e.g., dev, qa, prod)"
  type        = string
}
provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "qabyrody-tf-state-s3" {
  bucket = "qabyrody-tf-state-${var.environment}-s3"

  tags = {
    Name        = "qa by rody tf state s3"
    Environment = var.environment
  }
}

resource "aws_dynamodb_table" "qabyrody-terraform-locks-dynamo-db" {
  name = "qabyrody-terraform-locks-${var.environment}-db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = var.environment
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.qabyrody-tf-state-s3
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.qabyrody-terraform-locks-dynamo-db
}