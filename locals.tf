locals {
  k8s_cluster_tag_map = "${map(
    "", map(),
    "${var.k8s_cluster_tag==""? "dummy":var.k8s_cluster_tag}", map(
      format("kubernetes.io/cluster/%s",trimspace(element(split("=", var.k8s_cluster_tag), 0))),
      trimspace(element(split("=", var.k8s_cluster_tag), length(split("=", var.k8s_cluster_tag))+1))
    )
  )}"

  k8s_cluster_tags = "${local.k8s_cluster_tag_map[var.k8s_cluster_tag]}"

  k8s_public_lb_tag_map = "${map(
    "", map(),
    "${var.k8s_cluster_tag==""? "dummy":var.k8s_cluster_tag}", map(
      "kubernetes.io/role/elb", "1"
    )
  )}"

  k8s_private_lb_tag_map = "${map(
    "", map(),
    "${var.k8s_cluster_tag==""? "dummy":var.k8s_cluster_tag}", map(
      "kubernetes.io/role/internal-elb", "1"
    )
  )}"

  nat_uniq_subnets = "${distinct(concat(var.no_nat_subnet_index, keys(var.private_subnets)))}"
  nat_subnet_index = "${slice(local.nat_uniq_subnets, length(var.no_nat_subnet_index), length(local.nat_uniq_subnets))}"

  num_nat_gw_map = "${map(
    "zero", 0,
    "one", 1,
    "az", length(var.azs),
    "subnet", (length(local.nat_subnet_index)) * length(var.azs)
  )}"

  subnet_tagsets = "${merge(local.default_subnet_tagset, var.subnet_tagsets)}"
  subnet_optsets = "${merge(local.default_subnet_optset, var.subnet_optsets)}"

  enable_s3_endpoint       = "${lookup(var.vpc_opts, "enable_s3_endpoint", local.default_vpc_opts["enable_s3_endpoint"])}"
  enable_dynamodb_endpoint = "${lookup(var.vpc_opts, "enable_dynamodb_endpoint", local.default_vpc_opts["enable_dynamodb_endpoint"])}"
}
