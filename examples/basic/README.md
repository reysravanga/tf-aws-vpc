
# tf-aws-vpc example

Example of tf-aws-vpc for typical usages

## Usage

``` terraform
module "basic_vpc" {
  source = "github.com/ukslee/tf-aws-vpc.git?ref=v0.1.0"

  vpc_name = "basic-vpc"
  vpc_cidr = "10.10.0.0/16"

  vpc_tags = {
    "owner" = "example"
  }

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnets = {
    "0" = ["infra", "10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24", "infra", ""]
    "1" = ["app", "10.10.111.0/24", "10.10.112.0/24", "10.10.113.0/24", "app", ""]
    "2" = ["lb", "10.10.121.0/24", "10.10.122.0/24", "10.10.123.0/24", "lb", ""]
  }

  private_subnets = {
    "0" = ["app", "10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24", "app", ""]
    "1" = ["lb", "10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24", "lb", ""]
    "2" = ["cache", "10.10.31.0/24", "10.10.32.0/24", "10.10.33.0/24", "cache", ""]
    "3" = ["db", "10.10.41.0/24", "10.10.42.0/24", "10.10.43.0/24", "db", ""]
  }

  subnet_tagsets = {
    "infra" = {
      "purpose" = "infra"
      "owner"   = "example-service"
    }

    "app" = {
      "purpose" = "app"
      "owner"   = "example-service"
    }

    "lb" = {
      "purpose" = "lb"
      "owner"   = "example-service"
    }

    "cache" = {
      "purpose" = "cache"
      "owner"   = "example-service"
    }

    "db" = {
      "purpose" = "db"
      "owner"   = "example-service"
    }
  }

  k8s_cluster_tag = "sample_k8s_cluster=shared"

  k8s_lbsubnet_index = {
    "public"  = ["2"]
    "private" = ["1"]
  }
}
```

## Steps to run this example

1. Edit `terraform.tfvars` file to specify your aws cli profile name for test environment.
For more information about aws cli profile, please refer to [AWS document](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
1. Run below commands.
For more information about installing `terraform`, please refer to [Hashicorp document](https://learn.hashicorp.com/terraform/getting-started/install.html)

``` bash
$ terraform init
$ terraform plan
$ terraform apply
```
