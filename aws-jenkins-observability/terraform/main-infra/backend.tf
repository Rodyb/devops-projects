terraform {
  backend "s3" {
    bucket         = "qabyrody-tf-state-qa-s3"
    key            = "envs/qa/main.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "qabyrody-terraform-locks-qa-db"
    encrypt        = true
  }
}
