
# tf-aws-vpc

[![CircleCI](https://circleci.com/gh/ukslee/tf-aws-vpc/tree/master.svg?style=svg&circle-token=8ce4c4e45108572df75b9eb78d2e3798d07e26dc)](https://circleci.com/gh/ukslee/tf-aws-vpc/tree/master)

Terraform module creating an aws vpc with various options.

## Usage

### Simple example

``` terraform
module "simple_vpc" {
  source = "github.com/ukslee/tf-aws-vpc.git?ref=v0.1.0"

  vpc_name = "simple-vpc"
  vpc_cidr = "10.10.0.0/16"

  vpc_tags = {
    "owner" = "example"
  }

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnets = {
    "0" = ["infra", "10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24", "", ""]
    "1" = ["app", "10.10.111.0/24", "10.10.112.0/24", "10.10.113.0/24", "", ""]
    "2" = ["lb", "10.10.121.0/24", "10.10.122.0/24", "10.10.123.0/24", "", ""]
  }

  private_subnets = {
    "0" = ["app", "10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24", "", ""]
    "1" = ["lb", "10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24", "", ""]
    "2" = ["cache", "10.10.31.0/24", "10.10.32.0/24", "10.10.33.0/24", "", ""]
    "3" = ["db", "10.10.41.0/24", "10.10.42.0/24", "10.10.43.0/24", "", ""]
  }

  k8s_cluster_tag = "sample_k8s_cluster=shared"

  k8s_lbsubnet_index = {
    "public"  = ["2"]
    "private" = ["1"]
  }
}
```

### More detailed examples

* [Basic Example](https://github.com/ukslee/tf-aws-vpc/blob/master/examples/basic)
* [Minimal Example](https://github.com/ukslee/tf-aws-vpc/blob/master/examples/minimal)
* [Complete Example](https://github.com/ukslee/tf-aws-vpc/blob/master/examples/complete)

## Supported resources

* VPC
  * CIDR specification support
  * VPC endpoint support for S3, DynamoDB
  * DHCP option support (Not impletemented yet)
* Subnets
  * Multiple subnets support
  * Tagging support for K8s use-cases
  * Database subnet group support (Not impletemented yet)
  * Elasticache subnet group support (Not impletemented yet)
* Network gateways
  * Internet Gateway support
  * NAT Gateway support

## Out-of-scope usecases

Below use cases could be implemented with outer codes using output of this modules

* Aditional [aws_vpc_endpoint](https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html)
* [aws_redshift_subnet_group](https://www.terraform.io/docs/providers/aws/r/redshift_subnet_group.html)