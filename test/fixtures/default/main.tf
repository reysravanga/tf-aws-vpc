module "sample_mod" {
  source = "../../../"

  vpc_name = "sample-vpc-${terraform.workspace}"
  cidr     = "${var.cidr}"
  tags     = "${var.tags}"
}
