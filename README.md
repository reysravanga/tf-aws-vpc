
# tf-aws-vpc

[![CircleCI](https://circleci.com/gh/ukslee/tf-aws-vpc/tree/master.svg?style=svg&circle-token=8ce4c4e45108572df75b9eb78d2e3798d07e26dc)](https://circleci.com/gh/ukslee/tf-aws-vpc/tree/master)

Terraform module creating an aws vpc.

## Requirement

Target goal of this module is creating all basic resources AWS VPC related with production grade requirements.

* VPC
  * CIDR specification support
  * DHCP option support
  * VPC endpoint support for S3, DynamoDB
* Subnets
  * multiple subnets support
  * tagging support for K8s use-cases
  * subnet list change support
  * database subnet group support
  * elasticache subnet group support
* Network gateways
  * Internet Gateway support
  * NAT Gateway support
* Output
  * `vpc_id`
  * `subnet_ids`
  * `igw_ids`
* Out-of-Cover cases
  * Below cases need to be covered out-of-module code using Output of this modules
    * additional [aws_vpc_endpoint](https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html)
    * [aws_redshift_subnet_group](https://www.terraform.io/docs/providers/aws/r/redshift_subnet_group.html)