locals {
  nat_uniq_subnets = "${distinct(concat(var.no_nat_subnet_index, keys(var.private_subnets)))}"
  nat_subnet_index = "${slice(local.nat_uniq_subnets, length(var.no_nat_subnet_index), length(local.nat_uniq_subnets))}"

  num_nat_gw_map = "${map(
    "zero", 0,
    "one", 1,
    "az", length(var.azs),
    "subnet", length(local.nat_subnet_index) * length(var.azs)
  )}"

  enable_s3_endpoint       = "${lookup(var.vpc_opts, "enable_s3_endpoint", "true")}"
  enable_dynamodb_endpoint = "${lookup(var.vpc_opts, "enable_dynamodb_endpoint", "true")}"
}

resource "aws_eip" "nat_eips" {
  count = "${local.num_nat_gw_map[var.num_nat_eips]}"
  vpc   = true

  tags = {
    "Name" = "${format("%s-%s-nat-%d", var.vpc_name, terraform.workspace, count.index)}"
  }
}

module "sample_mod" {
  source = "../../../"

  vpc_name = "${var.vpc_name}-${terraform.workspace}"
  vpc_cidr = "${var.vpc_cidr}"
  vpc_tags = "${var.vpc_tags}"
  vpc_opts = "${var.vpc_opts}"

  azs             = "${var.azs}"
  public_subnets  = "${var.public_subnets}"
  private_subnets = "${var.private_subnets}"
  subnet_tagsets  = "${var.subnet_tagsets}"
  subnet_optsets  = "${var.subnet_optsets}"

  k8s_cluster_tag    = "${var.k8s_cluster_tag}"
  k8s_lbsubnet_index = "${var.k8s_lbsubnet_index}"

  nat_eips            = "${aws_eip.nat_eips.*.id}"
  num_nat_eips        = "${local.num_nat_gw_map[var.num_nat_eips]}"
  nat_mode            = "${var.nat_mode}"
  no_nat_subnet_index = "${var.no_nat_subnet_index}"
}

data "aws_vpc_endpoint" "s3" {
  count = "${local.enable_s3_endpoint == "true" ? 1 : 0}"
  id    = "${module.sample_mod.s3_vpc_endpoint_id}"
}

data "aws_vpc_endpoint" "dynamodb" {
  count = "${local.enable_dynamodb_endpoint == "true" ? 1 : 0}"
  id    = "${module.sample_mod.dynamodb_vpc_endpoint_id}"
}
