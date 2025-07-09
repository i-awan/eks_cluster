resource "aws_vpc_endpoint_service" "this" {
  acceptance_required        = var.acceptance_required
  network_load_balancer_arns = [var.nlb_arn]
}

resource "aws_vpc_endpoint" "this" {
  vpc_id              = var.vpc_id
  service_name        = aws_vpc_endpoint_service.this.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
  private_dns_enabled = var.private_dns_enabled

  tags = {
    Name = var.name
  }
}

resource "aws_vpc_endpoint_service_allowed_principal" "allow_all" {
  count                  = var.acceptance_required ? 0 : 1
  vpc_endpoint_service_id = aws_vpc_endpoint_service.this.id
  principal_arn           = "*"
}

resource "aws_route53_record" "dns" {
  zone_id = var.zone_id
  name    = var.dns_name
  type    = "CNAME"
  ttl     = 60
  records = [aws_vpc_endpoint.this.dns_entry[0].dns_name]
}
