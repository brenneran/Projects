terraform {
  backend "s3" {
    region         = "us-west-2"
    bucket         = "infra-terraform"
    key            = "jama/prod.tfstate"
    dynamodb_table = "infra-terraform"
  }
}
