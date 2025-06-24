variable "public" {
  type = map(string)
}

variable "private" {
  type = map(string)
}

variable "cluster_version" {
  type = string
  default = "1.32"
}