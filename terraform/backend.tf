terraform {
  backend "s3" {
    bucket         = "sourick-terraform-state-stroage"
    key            = "flask-project/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
