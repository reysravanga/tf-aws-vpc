resource "aws_vpc" "this" {
  cidr_block = "${var.cidr}"

  instance_tenancy                 = "${lookup(var.vpc_opts, "instance_tenancy", local.default_vpc_opts["instance_tenancy"])}"
  enable_dns_support               = "${lookup(var.vpc_opts, "enable_dns_support", local.default_vpc_opts["enable_dns_support"])}"
  enable_dns_hostnames             = "${lookup(var.vpc_opts, "enable_dns_hostnames", local.default_vpc_opts["enable_dns_hostnames"])}"
  assign_generated_ipv6_cidr_block = "${lookup(var.vpc_opts, "assign_generated_ipv6_cidr_block", local.default_vpc_opts["assign_generated_ipv6_cidr_block"])}"

  tags                             = "${merge(var.tags, map("Name", format("%s", var.vpc_name)))}"
}
