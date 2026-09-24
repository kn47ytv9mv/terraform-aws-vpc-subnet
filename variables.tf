variable "vpc_id" {
  default     = null
  description = "The ID of the VPC in which to create the subnet."
}

variable "cidr_block" {
  default     = null
  description = "IPv4 CIDR block for the subnet. Mutually exclusive with the ipv4_ipam_pool_id pair, which has AWS allocate the block instead."
}

variable "ipv4_ipam_pool_id" {
  default     = null
  description = "ID of an IPAM pool to allocate this subnet's IPv4 block from, from terraform-aws-ipam's regional_pool_ids. Pairs with ipv4_netmask_length, and is mutually exclusive with cidr_block."

  validation {
    condition     = var.ipv4_ipam_pool_id == null || var.cidr_block == null
    error_message = "cidr_block states the block explicitly and ipv4_ipam_pool_id has AWS allocate one; at most one may be set."
  }
}

variable "ipv4_netmask_length" {
  default     = null
  description = "Prefix length of the IPv4 block to request from ipv4_ipam_pool_id (e.g. 24 for a /24). Required when ipv4_ipam_pool_id is set."

  validation {
    condition     = (var.ipv4_ipam_pool_id == null) == (var.ipv4_netmask_length == null)
    error_message = "ipv4_ipam_pool_id and ipv4_netmask_length must be set together."
  }
}

variable "ipv6_cidr_block" {
  default     = null
  description = "IPv6 CIDR block for the subnet. AWS fixes IPv6 subnet blocks at /64, so the block supplied must be a /64 carved from the VPC's own /56. Mutually exclusive with the ipv6_ipam_pool_id pair."
}

variable "ipv6_ipam_pool_id" {
  default     = null
  description = "ID of an IPAM pool to allocate this subnet's IPv6 block from, from terraform-aws-ipam's regional_ipv6_pool_ids. Pairs with ipv6_netmask_length, and is mutually exclusive with ipv6_cidr_block."

  validation {
    condition     = var.ipv6_ipam_pool_id == null || var.ipv6_cidr_block == null
    error_message = "ipv6_cidr_block states the block explicitly and ipv6_ipam_pool_id has AWS allocate one; at most one may be set."
  }
}

variable "ipv6_netmask_length" {
  default     = null
  description = "Prefix length of the IPv6 block to request from ipv6_ipam_pool_id. AWS accepts only 64 for a subnet."

  validation {
    condition     = (var.ipv6_ipam_pool_id == null) == (var.ipv6_netmask_length == null)
    error_message = "ipv6_ipam_pool_id and ipv6_netmask_length must be set together."
  }
}

variable "ipv6_native" {
  default     = null
  description = "Whether the subnet is IPv6-only, with no IPv4 addressing at all. Requires an IPv6 block and forbids an IPv4 one. If null, AWS's own default (dual-stack or IPv4-only) applies."
}

variable "assign_ipv6_address_on_creation" {
  default     = null
  description = "Whether network interfaces created in this subnet receive an IPv6 address automatically. Without it, an instance in an IPv6-enabled subnet still comes up with no IPv6 address. If null, AWS's own default (disabled) applies."
}

variable "enable_dns64" {
  default     = null
  description = "Whether DNS queries return NAT64 addresses, letting IPv6-only instances reach IPv4-only services through a NAT gateway. If null, AWS's own default (disabled) applies."
}

variable "availability_zone" {
  default     = null
  description = "Availability zone for the subnet. If null, AWS assigns one automatically."
}

variable "availability_zone_id" {
  default     = null
  description = "Availability zone for the subnet, given by its account-stable ID (e.g. 'use1-az1') rather than its name. Zone names are shuffled per account, so two accounts' 'us-east-1a' are usually different physical zones — the ID is what makes placement comparable across accounts. Mutually exclusive with availability_zone."

  validation {
    condition     = var.availability_zone == null || var.availability_zone_id == null
    error_message = "At most one of availability_zone or availability_zone_id may be set."
  }
}

variable "private_dns_hostname_type_on_launch" {
  default     = null
  description = "How AWS derives the private DNS hostname of an instance launched here: 'ip-name' (from its IPv4 address) or 'resource-name' (from its instance ID, the only option that works for an IPv6-only subnet). If null, AWS's own default applies."
}

variable "map_public_ip_on_launch" {
  default     = false
  description = "Whether instances launched in this subnet receive a public IP address by default."
}

variable "associate_route_table" {
  default     = false
  description = "Whether this subnet is associated with route_table_id. This is a separate switch because Terraform requires the decision to be known before it plans, and the ID of a route table created in the same configuration is not — see the Design section. Without an association the VPC's default route table applies."

  validation {
    condition     = !var.associate_route_table || var.route_table_id != null
    error_message = "associate_route_table requires route_table_id to name the route table to associate with."
  }

  validation {
    condition     = var.route_table_id == null || var.associate_route_table
    error_message = "route_table_id is set but associate_route_table is false, so no association would be created. Set associate_route_table = true."
  }
}

variable "route_table_id" {
  default     = null
  description = "The ID of the route table to associate with this subnet, from terraform-aws-vpc-route-table. Requires associate_route_table. If no association is made, the VPC's default route table applies."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the subnet."
}
