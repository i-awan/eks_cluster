# VPC CIDR blocks
routable_cidr     = "10.10.0.0/16"
non_routable_cidr = "10.20.0.0/16"
#internal_cidr      = "10.30.0.0/16"

# London Region AZs
availability_zones = ["eu-west-2a", "eu-west-2b"]

# Optional override

aws_region = "eu-west-2"

zone_name              = "imranawan.com"
bastion_instance_type  = "t3.micro"
account_id             = "123456789012"  # Replace with your actual AWS account ID
