# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.sample_mod.vpc_id}"
}

# outputs for testing
## terraform.tfstate path
output "terraform_state" {
  description = "This output is used as an attribute in the state_file control"

  value = "${path.cwd}/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
}

# outputs for mirroring input variables
locals {
  variable_output_filename = "${path.cwd}/input_vars.json"
  variable_output_content =<<EOD
{
  "cidr": ${jsonencode(var.cidr)},
  "tags": ${jsonencode(var.tags)}
}
EOD
}

output "variable_output_filename" {
  description = "This output is used as an attribute in the state_file control"
  value       = "${local.variable_output_filename}"
}

resource "local_file" "variable_output_filename" {
  filename = "${local.variable_output_filename}"
  content = "${chomp(local.variable_output_content)}"
}
