# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.sample_mod.vpc_id}"
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
  "cidr": ${jsonencode(var.cidr)},
  "tags": ${jsonencode(var.tags)}
}
EOD
}

## terraform.tfstate path
output "terraform_state" {
  description = "This output is used as an attribute in the state_file control"

  value = "${local.terraform_state_filename}"
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
