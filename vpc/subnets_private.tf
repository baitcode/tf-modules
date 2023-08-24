resource "aws_subnet" "private_subnets" {
  count = length(local.private_subnet_cidrs)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  availability_zone = data.aws_availability_zones.current.names[count.index % local.az_count]

  tags = merge(var.tags, {
    "SubnetType": "Private"
    "Name": "${var.cluster_name}-private-${data.aws_availability_zones.current.names[count.index % local.az_count]}"
    "kubernetes.io/cluster/${var.cluster_name}": "shared"
    "kubernetes.io/role/internal-elb": 1
  })
}

// NAT

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

// Route table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name         = "${var.cluster_name}-private-route-table"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private_subnets)

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "nat_gateway_route_in_private_routetable" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

