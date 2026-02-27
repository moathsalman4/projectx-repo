resource "aws_dynamodb_table" "terraform_locks" {
  name         = "665832051028-terraform-lock-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

