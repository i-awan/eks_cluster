resource "aws_ec2_transit_gateway" "this" {
  description                     = "TGW for lab"
  amazon_side_asn                = 64512
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "lab-tgw"
  }
}
