locals {
  # Import outputs from the network state
  non_routable_vpc_id           = data.terraform_remote_state.network.outputs.non_routable_vpc_id
  non_routable_private_subnets  = data.terraform_remote_state.network.outputs.non_routable_private_subnet_ids
}

