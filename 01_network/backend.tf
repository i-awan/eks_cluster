# backend.tf (this is where the backend configuration goes)
terraform {
  backend "s3" {
    bucket = "eks-state-bucket-ia"
    key    = "01_network/terraform.tfstate"
    region = "eu-west-2"
    encrypt = true  # Enable encryption for state
  }
}
