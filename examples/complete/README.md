
# tf-aws-vpc example

simple example of tf-aws-vpc

## Usage

``` yaml
module "sample" {
   source = "github.com/ukslee/tf-aws-vpc?ref=test-fw"

   sample_variable = "sample"
}
```

## Steps to test run this example

1. edit `terraform.tfvars` file to specify your credential for test environment
1. run below commands

``` bash
$ terraform init
$ terraform plan
$ terraform apply
```