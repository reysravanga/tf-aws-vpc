module "sample_mod" {
  source = "github.com/ukslee/tf-module-skeleton.git?ref=v0.1.0"

  vpc_name = "eg-vpc-${terraform.workspace}"
}
