variable "vpc_cidr" {
  type    = string
}

variable "public" {
  type = map(string)
  description = "Map of availability zones for public subnets"
}

variable "private" {
  type = map(string)
  description = "Map of availability zones for private subnets"
}

