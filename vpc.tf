resource "aws_vpc" "this" {
  cidr_block = "${var.cidr}"

  instance_tenancy = "${lookup(var.vpc_opts, "instance_tenancy", local.default_vpc_opts["instance_tenancy"])}"
  tags             = "${merge(var.tags, map("Name", format("%s", var.vpc_name)))}"
}
