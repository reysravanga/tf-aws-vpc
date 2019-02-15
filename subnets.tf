# Public subnet resources
resource "aws_subnet" "public" {
  count = "${length(keys(var.public_subnets)) * length(var.azs)}"

  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${element(var.public_subnets[count.index / length(var.azs)], count.index % length(var.azs) + 1 )}"
  availability_zone = "${element(var.azs, count.index)}"

  map_public_ip_on_launch = "${lookup(
    local.subnet_optsets[element(var.public_subnets[count.index / length(var.azs)], length(var.azs) + 2)],
    "map_public_ip_on_launch",
    lookup(local.default_subnet_optset[""], "map_public_ip_on_launch")
    )}"

  assign_ipv6_address_on_creation = "${lookup(
    local.subnet_optsets[element(var.public_subnets[count.index / length(var.azs)], length(var.azs) + 2)],
    "assign_ipv6_address_on_creation",
    lookup(local.default_subnet_optset[""], "assign_ipv6_address_on_creation")
    )}"

  tags = "${merge( 
    local.subnet_tagsets[element(var.public_subnets[count.index / length(var.azs)], length(var.azs) + 1)],
    map("Name", format("%s.public.%s.%s",
                        var.vpc_name,element(var.public_subnets[count.index / length(var.azs)], 0),
                        substr(var.azs[count.index % length(var.azs)], -1, -1)) ),
    local.k8s_cluster_tags,
    local.k8s_public_lb_tag_map[contains(var.k8s_lbsubnet_index["public"], count.index / length(var.azs)) ? var.k8s_cluster_tag : ""]
  )}"
}

resource "aws_route_table" "public" {
  count = "${length(keys(var.public_subnets)) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"
  tags   = "${merge(var.vpc_tags, map("Name", format("%s.public.rt", var.vpc_name)))}"
}

resource "aws_route_table_association" "public" {
  count = "${length(keys(var.public_subnets)) > 0 ? length(keys(var.public_subnets)) * length(var.azs) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, 0)}"
}

# Private subnet resources
resource "aws_subnet" "private" {
  count = "${length(keys(var.private_subnets)) * length(var.azs)}"

  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${element(var.private_subnets[count.index / length(var.azs)], count.index % length(var.azs) + 1 )}"
  availability_zone = "${element(var.azs, count.index)}"

  map_public_ip_on_launch = "${lookup(
    local.subnet_optsets[element(var.private_subnets[count.index / length(var.azs)], length(var.azs) + 2)],
    "map_public_ip_on_launch")}"

  assign_ipv6_address_on_creation = "${lookup(
    local.subnet_optsets[element(var.private_subnets[count.index / length(var.azs)], length(var.azs) + 2)],
    "assign_ipv6_address_on_creation")}"

  tags = "${merge( 
    local.subnet_tagsets[element(var.private_subnets[count.index / length(var.azs)], length(var.azs) + 1)],
    map("Name", format("%s.private.%s.%s",
                        var.vpc_name,element(var.private_subnets[count.index / length(var.azs)], 0),
                        substr(var.azs[count.index % length(var.azs)], -1, -1)) ),
    local.k8s_cluster_tags,
    local.k8s_private_lb_tag_map[contains(var.k8s_lbsubnet_index["private"], count.index / length(var.azs)) ? var.k8s_cluster_tag : ""]
  )}"
}

resource "aws_route_table" "private" {
  count = "${length(keys(var.private_subnets)) * length(var.azs)}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.vpc_tags, map("Name", format("%s.private.%s.%s.rt",
                        var.vpc_name,element(var.private_subnets[count.index / length(var.azs)], 0),
                        substr(var.azs[count.index % length(var.azs)], -1, -1)) )
                   )}"
}

resource "aws_route_table_association" "private" {
  count = "${length(keys(var.private_subnets)) * length(var.azs)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
