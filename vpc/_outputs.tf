output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = [ for subnet in concat(aws_subnet.public_subnets, aws_subnet.private_subnets) : subnet.id ]
}

output "public_subnet_ids" {
  value = [ for subnet in concat(aws_subnet.public_subnets) : subnet.id ]
}

output "private_subnet_ids" {
  value = [ for subnet in concat(aws_subnet.private_subnets) : subnet.id ]
}
