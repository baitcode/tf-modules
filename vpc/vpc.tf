locals {
  vpc_network_bits = 16
  subnet_network_bits = 4
  prefix = "${var.network_prefix}/${local.vpc_network_bits}"
  az_count = length(data.aws_availability_zones.current.names)
  private_subnets_count = local.az_count
  public_subnets_count = local.az_count

  public_subnet_cidrs = [ for num in range(local.public_subnets_count): cidrsubnet(local.prefix, local.subnet_network_bits, num) ]
  private_subnet_cidrs = [ for num in range(local.private_subnets_count): cidrsubnet(local.prefix, local.subnet_network_bits, num + local.public_subnets_count) ]
  
  vpn_subnet_cidrs = [ 
    cidrsubnet(local.prefix, local.subnet_network_bits, local.public_subnets_count + local.private_subnets_count) 
  ]
}


resource "aws_vpc" "main" {
  cidr_block = local.prefix
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

data "aws_availability_zones" "current" {
  state = "available"
}

