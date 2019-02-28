# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.this.id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${aws_vpc.this.cidr_block}"
}

output "azs" {
  description = "The azs of subnets in the VPC"
  value       = "${var.azs}"
}

output "public_subnet_keys" {
  value = "${data.null_data_source.public_subnet_keys.*.outputs.key}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public.*.id}"
}

output "private_subnet_keys" {
  value = "${data.null_data_source.private_subnet_keys.*.outputs.key}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.private.*.id}"
}

output "public_route_table_id" {
  value = "${join(",", aws_route_table.public.*.id)}"
}

output "private_route_table_ids" {
  value = "${aws_route_table.private.*.id}"
}

output "igw_id" {
  value = "${join(",", aws_internet_gateway.igw.*.id)}"
}

output "ngw_ids" {
  value = "${aws_nat_gateway.ngw.*.id}"
}

output "nat_eips" {
  value = "${distinct(concat(aws_eip.ngw.*.id, var.nat_eips)) }"
}

output "nat_public_ips" {
  value = "${distinct(concat(aws_eip.ngw.*.public_ip, data.aws_eip.nat_eips.*.public_ip))}"
}

output "s3_vpc_endpoint_id" {
  value = "${join(",", aws_vpc_endpoint.s3.*.id)}"
}

output "dynamodb_vpc_endpoint_id" {
  value = "${join(",", aws_vpc_endpoint.dynamodb.*.id)}"
}
