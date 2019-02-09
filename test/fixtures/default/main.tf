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
}
