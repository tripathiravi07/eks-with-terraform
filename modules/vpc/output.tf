output "vpc_id" {
   value = aws_vpc.eks-vpc.id
}

output "private_subnets" {
  value = [for s in aws_subnet.eks-private-subnets: s.id]
}

output "public_subnets" {
  value = [for s in aws_subnet.eks-public-subnets : s.id]
}

output "all_subnet_ids" {
  description = "List of all subnet IDs (public + private)"
  value = concat(
    [for s in aws_subnet.eks-public-subnets : s.id],
    [for s in aws_subnet.eks-private-subnets : s.id]
  )
}