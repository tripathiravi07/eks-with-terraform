terraform {
  backend "s3" {
    bucket = "raviptri-env"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
