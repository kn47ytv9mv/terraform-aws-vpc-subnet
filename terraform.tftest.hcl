mock_provider "aws" {}

run "ipam_pool_and_netmask_must_be_set_together" {
  command = plan

  variables {
    vpc_id            = "vpc-1111"
    ipv4_ipam_pool_id = "ipam-pool-1111"
  }

  expect_failures = [var.ipv4_netmask_length]
}

run "ipam_pool_conflicts_with_an_explicit_cidr" {
  command = plan

  variables {
    vpc_id              = "vpc-1111"
    cidr_block          = "10.0.1.0/24"
    ipv4_ipam_pool_id   = "ipam-pool-1111"
    ipv4_netmask_length = 24
  }

  expect_failures = [var.ipv4_ipam_pool_id]
}

run "availability_zone_and_zone_id_are_mutually_exclusive" {
  command = plan

  variables {
    vpc_id               = "vpc-1111"
    cidr_block           = "10.0.1.0/24"
    availability_zone    = "us-east-1a"
    availability_zone_id = "use1-az1"
  }

  expect_failures = [var.availability_zone_id]
}

run "ipv6_ipam_pool_conflicts_with_an_explicit_ipv6_cidr" {
  command = plan

  variables {
    vpc_id              = "vpc-1111"
    cidr_block          = "10.0.1.0/24"
    ipv6_cidr_block     = "2600:1f18:1234:5600::/64"
    ipv6_ipam_pool_id   = "ipam-pool-2222"
    ipv6_netmask_length = 64
  }

  expect_failures = [var.ipv6_ipam_pool_id]
}

run "ipv6_ipam_pool_and_netmask_must_be_set_together" {
  command = plan

  variables {
    vpc_id            = "vpc-1111"
    cidr_block        = "10.0.1.0/24"
    ipv6_ipam_pool_id = "ipam-pool-2222"
  }

  expect_failures = [var.ipv6_netmask_length]
}

run "default_config_creates_subnet_no_association" {
  command = plan

  variables {
    vpc_id     = "vpc-0123456789abcdef0"
    cidr_block = "10.0.1.0/24"
  }

  assert {
    condition     = aws_subnet.resource.cidr_block == "10.0.1.0/24"
    error_message = "The subnet should use the given cidr_block."
  }

  assert {
    condition     = length(aws_route_table_association.resource) == 0
    error_message = "No route_table_id was given, so no route table association should be created."
  }
}

run "associating_a_route_table_creates_one_association" {
  command = plan

  variables {
    vpc_id                = "vpc-0123456789abcdef0"
    cidr_block            = "10.0.1.0/24"
    associate_route_table = true
    route_table_id        = "rtb-0123456789abcdef0"
  }

  assert {
    condition     = length(aws_route_table_association.resource) == 1
    error_message = "Setting route_table_id should create exactly one route table association."
  }

  assert {
    condition     = aws_route_table_association.resource[0].route_table_id == "rtb-0123456789abcdef0"
    error_message = "The association should use the given route_table_id."
  }
}

run "ipv6_settings_pass_through" {
  command = plan

  variables {
    vpc_id                          = "vpc-1111"
    cidr_block                      = "10.0.1.0/24"
    ipv6_cidr_block                 = "2600:1f18:1234:5600::/64"
    assign_ipv6_address_on_creation = true
    enable_dns64                    = true
  }

  assert {
    condition     = aws_subnet.resource.ipv6_cidr_block == "2600:1f18:1234:5600::/64"
    error_message = "The IPv6 block should pass through unchanged."
  }

  assert {
    condition     = aws_subnet.resource.assign_ipv6_address_on_creation == true
    error_message = "Without this, an instance in an IPv6-enabled subnet still comes up with no IPv6 address."
  }
}

run "ipam_allocation_passes_through" {
  command = plan

  variables {
    vpc_id              = "vpc-1111"
    ipv4_ipam_pool_id   = "ipam-pool-1111"
    ipv4_netmask_length = 24
  }

  assert {
    condition     = aws_subnet.resource.ipv4_netmask_length == 24
    error_message = "An IPAM-allocated subnet should request its size by netmask length."
  }
}

run "readme_minimal" {
  command = plan

  variables {
    vpc_id     = "vpc-0123456789abcdef0"
    cidr_block = "10.0.1.0/24"
  }
}

run "readme_with_route_table_association" {
  command = plan

  variables {
    vpc_id                = "vpc-0123456789abcdef0"
    cidr_block            = "10.0.1.0/24"
    associate_route_table = true
    route_table_id        = "rtb-0123456789abcdef0"
  }

  assert {
    condition     = length(aws_route_table_association.resource) == 1
    error_message = "The README's composed example should produce one route table association."
  }
}

run "associating_without_a_route_table_id_is_rejected" {
  command = plan

  variables {
    vpc_id                = "vpc-0123456789abcdef0"
    cidr_block            = "10.0.1.0/24"
    associate_route_table = true
  }

  expect_failures = [var.associate_route_table]
}

run "a_route_table_id_without_associating_is_rejected" {
  command = plan

  variables {
    vpc_id         = "vpc-0123456789abcdef0"
    cidr_block     = "10.0.1.0/24"
    route_table_id = "rtb-0123456789abcdef0"
  }

  expect_failures = [var.associate_route_table]
}
