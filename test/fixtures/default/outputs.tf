# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.sample_mod.vpc_id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${module.sample_mod.vpc_cidr_block}"
}

output "public_subnet_ids" {
  value = "${module.sample_mod.public_subnet_ids}"
}

output "private_subnet_ids" {
  value = "${module.sample_mod.private_subnet_ids}"
}

# outputs for testing
# outputs for mirroring input variables
locals {
  terraform_state_filename = "${path.cwd}/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  tfstate_info_filename    = "${path.cwd}/tfstate_info.json"

  tfstate_info_content = <<EOD
{
  "tfstate_path": ${jsonencode(local.terraform_state_filename)},
  "tf_workspace": ${jsonencode(terraform.workspace)}
}
EOD

  tfinput_filename = "${path.cwd}/input_vars.json"

  tfinput_content = <<EOD
{
  "vpc_name": ${jsonencode(var.vpc_name)},
  "vpc_cidr": ${jsonencode(var.vpc_cidr)},
  "vpc_tags": ${jsonencode(var.vpc_tags)},
  "vpc_opts": ${jsonencode(var.vpc_opts)},

  "azs": ${jsonencode(var.azs)},
  "public_subnets": ${jsonencode(var.public_subnets)},
  "private_subnets": ${jsonencode(var.private_subnets)},
  "subnet_tagsets": ${jsonencode(var.subnet_tagsets)},
  "subnet_optsets": ${jsonencode(var.subnet_optsets)},
  "dbsubnet_index": ${jsonencode(var.dbsubnet_index)},
  "cachesubnet_index": ${jsonencode(var.dbsubnet_index)},

  "k8s_cluster_tag": ${jsonencode(var.k8s_cluster_tag)},
  "k8s_lbsubnet_index": ${jsonencode(var.k8s_lbsubnet_index)},

  "nat_eips": ${jsonencode(aws_eip.nat_eips.*.id)},
  "nat_mode": ${jsonencode(var.nat_mode)},
  "no_nat_subnet_index": ${jsonencode(var.no_nat_subnet_index)},
  "num_nat_eips": ${jsonencode(var.num_nat_eips)},

  "build_num": ${jsonencode(local.build_num)}
}
EOD
}

output "terraform_state" {
  description = "This output is used as an attribute in the state_file control"

  value = "${local.terraform_state_filename}"
}

output "terraform_workspace" {
  description = "This output is used as an attribute in the state_file control"

  value = "${terraform.workspace}"
}

output "tfinput_filename" {
  description = "This output is used as an attribute in the state_file control"
  value       = "${local.tfinput_filename}"
}

resource "local_file" "tfinput_file" {
  filename = "${local.tfinput_filename}"
  content  = "${chomp(local.tfinput_content)}"
}

resource "local_file" "tfstate_info_file" {
  filename = "${local.tfstate_info_filename}"
  content  = "${chomp(local.tfstate_info_content)}"
}

output "s3_prefix_list_id" {
  value = "${join(",", data.aws_vpc_endpoint.s3.*.prefix_list_id)}"
}

output "dynamodb_prefix_list_id" {
  value = "${join(",", data.aws_vpc_endpoint.dynamodb.*.prefix_list_id)}"
}
