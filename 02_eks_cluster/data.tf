data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "eks-state-bucket-ia"
    key    = "env:/dev/01_network/terraform.tfstate"
    region = "eu-west-2"
  }
}
