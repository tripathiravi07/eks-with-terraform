variable "public" {
  description = "Map of public subnet availability zones"
  type        = map(string)
}

variable "private" {
  description = "Map of private subnet availability zones"
  type        = map(string)
}

variable "version" {
  description = "Kubernetes cluster version"
  type        = string
}