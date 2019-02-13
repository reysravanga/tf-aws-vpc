# VPC endpoint for s3
data "aws_vpc_endpoint_service" "s3" {
  count = "${local.enable_s3_endpoint =="true" ? 1 : 0}"

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = "${local.enable_s3_endpoint =="true" ? 1 : 0}"

  vpc_id       = "${aws_vpc.this.id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = "${local.enable_s3_endpoint =="true" ? length(keys(var.private_subnets)) * length(var.azs) : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = "${local.enable_s3_endpoint =="true" && length(keys(var.public_subnets)) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${join(",", aws_route_table.public.*.id)}"
}

# VPC endpoint for dynamodb
data "aws_vpc_endpoint_service" "dynamodb" {
  count = "${local.enable_dynamodb_endpoint =="true" ? 1 : 0}"

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = "${local.enable_dynamodb_endpoint =="true" ? 1 : 0}"

  vpc_id       = "${aws_vpc.this.id}"
  service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = "${local.enable_dynamodb_endpoint =="true" ? length(keys(var.private_subnets)) * length(var.azs) : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = "${local.enable_dynamodb_endpoint =="true" && length(keys(var.public_subnets)) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${join(",", aws_route_table.public.*.id)}"
}
