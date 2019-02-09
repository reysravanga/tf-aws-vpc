locals {
  subnet_tagsets = "${merge(local.default_subnet_tagset, var.subnet_tagsets)}"
  subnet_optsets = "${merge(local.default_subnet_optset, var.subnet_optsets)}"
}
