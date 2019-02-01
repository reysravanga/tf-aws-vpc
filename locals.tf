locals {
  default_vpc_opts = {
    instance_tenancy                 = "default"
    enable_dns_support               = "true"
    enable_dns_hostnames             = "false"
    assign_generated_ipv6_cidr_block = "false"
  }
}
