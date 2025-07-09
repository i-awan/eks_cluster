# 01_network/main.tf

module "routable_vpc" {
  source              = "../modules/vpc"
  name                = "routable"
  cidr_block          = var.routable_cidr
  availability_zones  = var.availability_zones
}

module "non_routable_vpc" {
  source              = "../modules/vpc"
  name                = "non-routable"
  cidr_block          = var.non_routable_cidr
  availability_zones  = var.availability_zones
}

module "tgw" {
  source           = "../modules/tgw"
}

resource "aws_security_group" "ssm_endpoint_sg" {
  for_each = {
    non_routable  = module.non_routable_vpc.vpc_id
    routable      = module.routable_vpc.vpc_id   # ← Add this line
  }

  name_prefix = "ssm-endpoint-${each.key}"
  vpc_id      = each.value

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssm-endpoint-${each.key}"
  }
}


locals {
  ssm_vpcs = {
    non_routable = {
      vpc_id              = module.non_routable_vpc.vpc_id
      private_subnet_ids  = module.non_routable_vpc.private_subnet_ids
    }
  }

  ssm_services = [
    "com.amazonaws.${var.aws_region}.ssm",
    "com.amazonaws.${var.aws_region}.ec2messages",
    "com.amazonaws.${var.aws_region}.ssmmessages"
  ]

  ssm_endpoints = merge([
    for vpc_key, vpc in local.ssm_vpcs : {
      for service in local.ssm_services :
      "${vpc_key}-${replace(service, ".", "-")}" => {
        vpc_id  = vpc.vpc_id
        service = service
        sg_id   = aws_security_group.ssm_endpoint_sg[vpc_key].id
        subnets = vpc.private_subnet_ids
      }
    }
  ]...)
}

resource "aws_vpc_endpoint" "ssm_endpoints" {
  for_each = local.ssm_endpoints

  vpc_id             = each.value.vpc_id
  service_name       = each.value.service
  vpc_endpoint_type  = "Interface"
  subnet_ids         = each.value.subnets
  security_group_ids = [each.value.sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-endpoint-${each.key}"
  }
}
