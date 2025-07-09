terraform {
  backend "s3" {
    bucket = "eks-state-bucket-ia"
    key    = "04_iam_ops_user/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "iam_ops_user" {
  source = "../modules/iam_ops_user"
  role_name            = "ops-readonly-role"
  user_arn             = "arn:aws:iam::1234566789001:user/ops-alice"
  source_ip            = "52.94.236.248"
  namespace            = "ops"
  service_account_name = "ops-reader"
  kubeconfig_path      = "~/.kube/config"
}
