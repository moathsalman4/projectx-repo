terraform {
  required_version = ">= 1.6.6"

  backend "s3" {
    bucket         = "665832051028-terraform-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "665832051028-terraform-lock-dev"
  }
}