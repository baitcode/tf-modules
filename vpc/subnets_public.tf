resource "aws_subnet" "public_subnets" {
  count = length(local.public_subnet_cidrs)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  availability_zone = data.aws_availability_zones.current.names[count.index % local.az_count]

  tags = merge(var.tags, {
    "SubnetType": "Public"
    "Name": "${var.cluster_name}-public-${data.aws_availability_zones.current.names[count.index % local.az_count]}"
    "kubernetes.io/cluster/${var.cluster_name}": "owned"
    "kubernetes.io/role/elb": 1
  })
}

// Route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name        = "${var.cluster_name}-public-route-table"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public_subnets)
  
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

// IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name        = "${var.cluster_name}-igw"
    Environment = var.cluster_name
  })
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}