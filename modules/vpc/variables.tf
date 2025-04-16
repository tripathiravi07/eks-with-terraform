variable "vpc_cidr" {
  type    = string
}

variable "public" {
  type = map(string)
  default = {
    "0" = "us-east-1a"
    "1" = "us-east-1b"
    "2" = "us-east-1c"
  }
}

variable "private" {
  type = map(string)
  default = {
    "3" = "us-east-1a"
    "4" = "us-east-1b"
    "5" = "us-east-1c"
  }
}
