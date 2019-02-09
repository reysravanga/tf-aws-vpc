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

  subnet_tagsets = "${merge(local.default_subnet_tagset, var.subnet_tagsets)}"
  subnet_optsets = "${merge(local.default_subnet_optset, var.subnet_optsets)}"
}
