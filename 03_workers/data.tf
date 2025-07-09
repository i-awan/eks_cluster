data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "eks-state-bucket-ia"
    key    = "env:/dev/01_network/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "eks-state-bucket-ia"
    key    = "env:/dev/02_eks_cluster/terraform.tfstate"
    region = "eu-west-2"
  }
}
