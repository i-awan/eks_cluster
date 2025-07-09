# 03_Workers/main.tf


module "workers" {
  source            = "../modules/worker"
  name              = var.name
  cluster_name      = data.terraform_remote_state.cluster.outputs.cluster_name
  instance_type     = var.instance_type
  subnet_ids        = data.terraform_remote_state.network.outputs.non_routable_private_subnet_ids
  security_group_ids = [data.terraform_remote_state.cluster.outputs.node_security_group_id]
  desired_capacity  = var.desired_capacity
  min_size          = var.min_size
  max_size          = var.max_size
}