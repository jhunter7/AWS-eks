# terraform.tf
# Configure backend to use s3 bucket with dynamodb_table for LOCKING

# Temp switch to NPD from LAB
# Figure out how to do this.

# Lab
terraform {
  required_version = "~> 0.12.0"
  backend "s3" {
    encrypt = true
    region  = "us-east-1"
  }
}

# NPD
# terraform {
#   backend "s3" {
#     encrypt        = true
#     bucket         = "kemper-npd-npd-terraform-s3-us-east-1"
#     dynamodb_table = "terraform-state-lock-dynamo"
#     region         = "us-east-1"
#     key            = "terraform/eks.tfstate"
#   }
# }
