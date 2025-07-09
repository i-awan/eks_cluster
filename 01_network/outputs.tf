# 01_network/outputs.tf

output "routable_vpc_id" {
  value = module.routable_vpc.vpc_id
}

output "routable_private_subnet_ids" {
  value = module.routable_vpc.private_subnet_ids
}

output "non_routable_vpc_id" {
  value = module.non_routable_vpc.vpc_id
}

output "non_routable_private_subnet_ids" {
  value = module.non_routable_vpc.private_subnet_ids
}

output "ssm_endpoint_sg_ids" {
  value = {
    non_routable  = aws_security_group.ssm_endpoint_sg["non_routable"].id
    routable      = aws_security_group.ssm_endpoint_sg["routable"].id # Make sure this SG exists
  }
}



