variable "public" {
  type = map(string)
}

variable "private" {
  type = map(string)
}

variable "cluster_version" {
  default = "1.32"
}