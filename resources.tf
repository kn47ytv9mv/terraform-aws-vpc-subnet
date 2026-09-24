resource "aws_subnet" "resource" {
  vpc_id = var.vpc_id

  cidr_block          = var.cidr_block
  ipv4_ipam_pool_id   = var.ipv4_ipam_pool_id
  ipv4_netmask_length = var.ipv4_netmask_length

  ipv6_cidr_block     = var.ipv6_cidr_block
  ipv6_ipam_pool_id   = var.ipv6_ipam_pool_id
  ipv6_netmask_length = var.ipv6_netmask_length
  ipv6_native         = var.ipv6_native

  availability_zone    = var.availability_zone
  availability_zone_id = var.availability_zone_id

  map_public_ip_on_launch             = var.map_public_ip_on_launch
  assign_ipv6_address_on_creation     = var.assign_ipv6_address_on_creation
  enable_dns64                        = var.enable_dns64
  private_dns_hostname_type_on_launch = var.private_dns_hostname_type_on_launch

  tags = var.tags
}

resource "aws_route_table_association" "resource" {
  count = var.associate_route_table ? 1 : 0

  subnet_id      = aws_subnet.resource.id
  route_table_id = var.route_table_id
}

output "id" {
  description = "The ID of the subnet."
  value       = aws_subnet.resource.id
}

output "arn" {
  description = "The ARN of the subnet."
  value       = aws_subnet.resource.arn
}

output "cidr_block" {
  description = "The IPv4 CIDR block of the subnet."
  value       = aws_subnet.resource.cidr_block
}

output "availability_zone" {
  description = "The availability zone of the subnet."
  value       = aws_subnet.resource.availability_zone
}

output "ipv6_cidr_block" {
  description = "The IPv6 CIDR block of the subnet, when one was assigned."
  value       = aws_subnet.resource.ipv6_cidr_block
}
