# internet gateway resources
resource "aws_internet_gateway" "igw" {
  count = "${length(keys(var.public_subnets)) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"
  tags   = "${merge(var.vpc_tags, map("Name", format("%s.igw", var.vpc_name)))}"
}

resource "aws_route" "igw" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${element(aws_internet_gateway.igw.*.id, count.index)}"
}

# NAT gateway resources
resource "aws_eip" "ngw" {
  count = "${var.num_nat_eips > 0 ? 0 : local.num_nat_gw_map[var.nat_mode]}"
  vpc   = true

  tags = "${merge(var.vpc_tags, map("Name", format("%s.ngw.%d", var.vpc_name, count.index)))}"
}

data "aws_eip" "nat_eips" {
  count = "${var.num_nat_eips}"

  id = "${element(var.nat_eips, count.index)}"
}

resource "aws_nat_gateway" "ngw" {
  count = "${local.num_nat_gw_map[var.nat_mode]}"

  allocation_id = "${element(concat(aws_eip.ngw.*.id, var.nat_eips), count.index) }"
  subnet_id     = "${element(slice(aws_subnet.public.*.id, 0, length(var.azs)), count.index % length(var.azs)) }"

  tags = "${merge(var.vpc_tags, map("Name", format("%s.ngw.%d", var.vpc_name, count.index)))}"
}

resource "aws_route" "ngw" {
  count = "${local.num_nat_gw_map[var.nat_mode] > 0 ? length(local.nat_subnet_index) * length(var.azs) : 0}"

  route_table_id = "${element(aws_route_table.private.*.id,
                              local.nat_subnet_index[count.index / length(var.azs)] * length(var.azs) + count.index % length(var.azs))}"

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.ngw.*.id, count.index % length(aws_nat_gateway.ngw.*.id))}"
}
