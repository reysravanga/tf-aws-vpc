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

#
# Subnet config map
#   {idx} = [ {name}, {cidr for the 1st az} ... {cidr for the last az}, {tagset}, {optset} ]
#
# Option value "" for {tagset}, {optset} will use empty tagset and module default optset
#
# Example with 3 azs case:
#  public_subnets = {
#    "0" = ["infra", "10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24", "infra_tag", "infra_opt"]
#    "1" = ["app", "10.10.111.0/24", "10.10.112.0/24", "10.10.113.0/24", "", ""]
#    "2" = ["lb", "10.10.121.0/24", "10.10.122.0/24", "10.10.123.0/24", "lb_tag", "lb_opt"]
#  }
#
variable "public_subnets" {
  description = "public subnets"
  type        = "map"
}

variable "private_subnets" {
  description = "private subnets"
  type        = "map"
}

#
# Subnet option config map
#
# Available options:
#  - instance_tenancy: *default / dedicated
#  - enable_dns_support: *true / false
#  - enable_dns_hostnames: true / *false
#  - assign_generated_ipv6_cidr_block: true / *false
#  - enable_s3_endpoint: *true / false
#  - enable_dynamodb_endpoint: *true / false
# Note: Module default value is marked with '*' like *true
#
# Example case:
#  subnet_optsets = {
#    "infra_opt" = {
#      "map_public_ip_on_launch"         = "true"
#      "assign_ipv6_address_on_creation" = "false"
#    }
#  }
#
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

#
# Nat gateway deploy mode
#
# Available options:
#  - zero: No Nat gateway
#  - one: One Nat gateway for every private subnets
#  - az: One Nat gateway per az.
#        Every private subnets will be mapped to a Nat gateway in the same az
#  - subnet: One Nat gateway per subnet.
#            Every private subnets will have dedicated Nat gateway in the same az
#
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
