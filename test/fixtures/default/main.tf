module "sample_mod" {
  source = "../../../"

  vpc_name = "${var.vpc_name}-${terraform.workspace}"
  cidr     = "${var.cidr}"
  tags     = "${var.tags}"
}
