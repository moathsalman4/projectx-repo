output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.projectx_vpc.id
}

output "public_subnet_ids_ordered" {
  description = "Public subnet IDs ordered by key"
  value       = [for k in sort(keys(aws_subnet.public)) : aws_subnet.public[k].id]
}

output "private_subnet_ids_ordered" {
  description = "Private subnet IDs ordered by key"
  value       = [for k in sort(keys(aws_subnet.private)) : aws_subnet.private[k].id]
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private_rt.id
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  value       = [for k in sort(keys(aws_subnet.public)) : aws_subnet.public[k].cidr_block]
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  value       = [for k in sort(keys(aws_subnet.private)) : aws_subnet.private[k].cidr_block]
}