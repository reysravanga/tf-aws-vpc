module "sample_mod" {
  source = "../../../"

  vpc_name = "sample-vpc-${terraform.workspace}"
  cidr = "10.10.0.0/16"
}
