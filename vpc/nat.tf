
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(var.tags, {
    Name        = "${var.cluster_name}-nat"
  })
}