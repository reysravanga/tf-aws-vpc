
# tf-aws-vpc example

Example of tf-aws-vpc usage with minimal input variables

## Usage

``` yaml
module "minimal_vpc" {
  source = "github.com/ukslee/tf-aws-vpc.git?ref=v0.1.0"

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
