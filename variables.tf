variable "vpc_name" {
  description = "The vpc name"
  type        = "string"
}

variable "vpc_cidr" {
  description = "The cidr block for the VPC (ex. 10.x.0.0/16)"
  type        = "string"
  default     = "10.10.0.0/16"
}

variable "vpc_tags" {
  description = "The tag map for vpc"
  type        = "map"
  default     = {}
}

variable "vpc_opts" {
  description = "The additional options for the VPC resource"
  type        = "map"
  default     = {}
}

variable "azs" {
  description = "The AZs for subnets"
  type        = "list"
}

variable "public_subnets" {
  description = "public subnets"
  type        = "map"

  default = {
    "0" = ["infra", "10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24", "", ""]
  }
}

variable "private_subnets" {
  description = "private subnets"
  type        = "map"

  default = {
    "0" = ["app", "10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24", "", ""]
  }
}

variable "subnet_optsets" {
  description = "option set maps for subnets"
  type        = "map"

  default = {}
}

variable "subnet_tagsets" {
  description = "tag set maps for subnets"
  type        = "map"

  default = {}
}

variable "k8s_cluster_tag" {
  description = "k8s cluster name and resource lifecycle value: <clustername>=<owned/shared>"
  type        = "string"
  default     = ""
}

variable "k8s_lbsubnet_index" {
  description = "The subnet index values for k8s loadbalancers"
  type        = "map"

  default = {
    "public"  = []
    "private" = []
  }
}

variable "no_nat_subnet_index" {
  description = "The subnet index values for private subnets without NAT gateway route"
  type        = "list"

  default = []
}

variable "dbsubnet_index" {
  description = "The subnet index values for aws_db_subnet_group"
  type        = "map"
  default     = {}
}

variable "cachesubnet_index" {
  description = "The subnet index values for aws_elasticache_subnet_group"
  type        = "map"
  default     = {}
}

variable "nat_mode" {
  description = "Nat gateway provisioning mode (zero/one/az/subnet)"
  type        = "string"
  default     = "one"
}

variable "nat_eips" {
  description = "Pre-allocated Elastic Ips for Nat gateways. if it is supplied, its count should be match with the number of required Nat gateways regarding `nat_mode` option"
  type        = "list"
  default     = []
}

variable "num_nat_eips" {
  description = "Number of pre-allocated Elastic Ips for Nat gateways. if it is supplied, it should be equal to the number of required Nat gateways regarding `nat_mode` option"
  default     = 0
}
