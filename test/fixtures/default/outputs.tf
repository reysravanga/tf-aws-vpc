# terraform.tfstate path
output "terraform_state" {
  description = "This output is used as an attribute in the state_file control"

  value = <<EOV
${path.cwd}/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate
EOV
}

# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.sample_mod.vpc_id}"
}
