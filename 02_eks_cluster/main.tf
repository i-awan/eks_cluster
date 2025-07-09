# 02_eks_cluster/main.tf


module "eks_cluster" {
  source                  = "../modules/eks"
  name                    = var.cluster_name
  vpc_id                  = local.non_routable_vpc_id
  private_subnet_ids      = local.non_routable_private_subnets
  eks_role_name           = var.eks_role_name
  endpoint_public_access  = true
  endpoint_private_access = false
}