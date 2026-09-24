# terraform-aws-vpc-subnet

Terraform module for a VPC subnet with an optional route table association.

## Cost

Subnets and route table associations carry no charge. This module has
no cost impact of its own.

### Why associating a route table takes a switch

`associate_route_table` beside `route_table_id` reads like a switch you
should not need. It exists because **Terraform decides how many resources
to create before it knows any value AWS computes.** A route table built
in the same configuration has no ID yet at plan time, so gating the
association on `route_table_id != null` fails outright with *"the for_each
set includes values derived from resource attributes that cannot be
determined until apply"* — which is the ordinary case, not an edge case.

A boolean the caller writes is always known at plan time, so the gate
holds wherever the ID comes from. Supplying one without the other is
rejected in both directions rather than silently ignored.

## Usage

```hcl
module "subnet" {
  source = "kn47ytv9mv/vpc-subnet/aws"

  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
}
```

Or directly from this repository:

```hcl
module "subnet" {
  source = "github.com/kn47ytv9mv/terraform-aws-vpc-subnet"

  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
}
```

Associate the subnet with a route table using
[`terraform-aws-vpc-route-table`](https://github.com/kn47ytv9mv/terraform-aws-vpc-route-table):

```hcl
module "route_table" {
  source = "kn47ytv9mv/vpc-route-table/aws"

  vpc_id = aws_vpc.example.id

  routes = [
    {
      destination_cidr_block = "0.0.0.0/0"
      gateway_id             = aws_internet_gateway.example.id
    }
  ]
}

module "subnet" {
  source = "kn47ytv9mv/vpc-subnet/aws"

  vpc_id         = aws_vpc.example.id
  cidr_block     = "10.0.1.0/24"
  associate_route_table = true
  route_table_id        = module.route_table.id
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.9 |
| aws | ~> 6.61 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| vpc_id | The ID of the VPC in which to create the subnet. | `null` | no |
| cidr_block | IPv4 CIDR block for the subnet. Mutually exclusive with the `ipv4_ipam_pool_id` pair. | `null` | no |
| ipv4_ipam_pool_id | IPAM pool to allocate the IPv4 block from, from `terraform-aws-ipam`'s `regional_pool_ids`. Pairs with `ipv4_netmask_length`. | `null` | no |
| ipv4_netmask_length | Prefix length to request from `ipv4_ipam_pool_id`. Required when that is set. | `null` | no |
| ipv6_cidr_block | IPv6 CIDR block. AWS fixes subnet IPv6 blocks at /64, carved from the VPC's /56. | `null` | no |
| ipv6_ipam_pool_id | IPAM pool to allocate the IPv6 block from, from `terraform-aws-ipam`'s `regional_ipv6_pool_ids`. | `null` | no |
| ipv6_netmask_length | Prefix length to request from `ipv6_ipam_pool_id`. AWS accepts only 64 for a subnet. | `null` | no |
| ipv6_native | Whether the subnet is IPv6-only, with no IPv4 addressing. | `null` | no |
| availability_zone_id | Availability zone by its account-stable ID (e.g. `'use1-az1'`) rather than its name. Zone names are shuffled per account. Mutually exclusive with `availability_zone`. | `null` | no |
| assign_ipv6_address_on_creation | Whether interfaces receive an IPv6 address automatically. Without it, an instance in an IPv6 subnet comes up with no IPv6 address. | `null` | no |
| enable_dns64 | Whether DNS returns NAT64 addresses, letting IPv6-only instances reach IPv4-only services. | `null` | no |
| private_dns_hostname_type_on_launch | `'ip-name'` or `'resource-name'` — the latter is the only option that works for an IPv6-only subnet. | `null` | no |
| availability_zone | Availability zone for the subnet. If null, AWS assigns one automatically. | `null` | no |
| map_public_ip_on_launch | Whether instances launched in this subnet receive a public IP address by default. | `false` | no |
| associate_route_table | Whether this subnet is associated with `route_table_id`. Separate from the ID because Terraform needs the decision known at plan time — see Design. | `false` | no |
| route_table_id | The ID of the route table to associate with this subnet. If null, the VPC's default route table applies. | `null` | no |
| tags | A map of tags to assign to the subnet. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the subnet. |
| arn | The ARN of the subnet. |
| cidr_block | The IPv4 CIDR block of the subnet. |
| availability_zone | The availability zone of the subnet. |
| ipv6_cidr_block | The IPv6 CIDR block of the subnet, when one was assigned. |

## License

MIT — see [LICENSE.md](LICENSE.md).
