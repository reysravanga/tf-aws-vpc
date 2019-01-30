resource "aws_vpc" "this" {
  cidr_block = "${var.cidr}"

  tags = "${merge(var.tags, map("Name", format("%s", var.vpc_name)))}"
}
