provider "aws" {
  region  = "us-east-1"
  profile = "${var.aws_profile}"
}

module "minimal_vpc" {
  source = "github.com/ukslee/tf-aws-vpc.git?ref=subnet_tags"

  vpc_name = "minimal-vpc"
  vpc_cidr = "10.10.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnets = {
    "0" = ["infra", "10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24", "", ""]
  }

  private_subnets = {
    "0" = ["app", "10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24", "", ""]
  }
}
