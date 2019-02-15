provider "aws" {
  region  = "us-east-1"
  profile = "${var.aws_profile}"
}

module "complete_vpc" {
  source = "github.com/ukslee/tf-aws-vpc.git?ref=v0.1.0"

  vpc_name = "complete-vpc"
  vpc_cidr = "10.10.0.0/16"

  vpc_tags = {
    "owner" = "example"
  }

  vpc_opts = {
    "instance_tenancy"                 = "default"
    "enable_dns_support"               = "true"
    "enable_dns_hostnames"             = "false"
    "assign_generated_ipv6_cidr_block" = "false"
    "enable_s3_endpoint"               = "true"
    "enable_dynamodb_endpoint"         = "true"
  }

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnets = {
    "0" = ["infra", "10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24", "infra_tag", "infra_opt"]
    "1" = ["app", "10.10.111.0/24", "10.10.112.0/24", "10.10.113.0/24", "app_tag", ""]
    "2" = ["lb", "10.10.121.0/24", "10.10.122.0/24", "10.10.123.0/24", "lb_tag", ""]
    "3" = ["lb-trust", "10.10.151.0/24", "10.10.152.0/24", "10.10.153.0/24", "lb_tag", ""]
  }

  private_subnets = {
    "0" = ["app", "10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24", "app_tag", ""]
    "1" = ["lb", "10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24", "lb_tag", ""]
    "2" = ["cache", "10.10.31.0/24", "10.10.32.0/24", "10.10.33.0/24", "cache_tag", ""]
    "3" = ["db", "10.10.41.0/24", "10.10.42.0/24", "10.10.43.0/24", "db_tag", ""]
  }

  subnet_optsets = {
    "infra_opt" = {
      "map_public_ip_on_launch" = "true"
    }
  }

  subnet_tagsets = {
    "infra_tag" = {
      "purpose" = "infra"
      "owner"   = "example-service"
    }

    "app_tag" = {
      "purpose" = "app"
      "owner"   = "example-service"
    }

    "lb_tag" = {
      "purpose" = "lb"
      "owner"   = "example-service"
    }

    "cache_tag" = {
      "purpose" = "cache"
      "owner"   = "example-service"
    }

    "db_tag" = {
      "purpose" = "db"
      "owner"   = "example-service"
    }
  }

  k8s_cluster_tag = "sample_k8s_cluster=shared"

  k8s_lbsubnet_index = {
    "public"  = ["2", "3"]
    "private" = ["1"]
  }

  dbsubnet_index = {
    "private" = ["3"]
  }

  cachesubnet_index = {
    "private" = ["2"]
  }

  nat_mode            = "az"
  nat_eips            = "${aws_eip.nat_eips.*.id}"
  num_nat_eips        = 3
  no_nat_subnet_index = ["2", "3"]
}

resource "aws_eip" "nat_eips" {
  count = 3
  vpc   = true

  tags = {
    "Name" = "${format("completeVPC-nat-%d", count.index)}"
  }
}
