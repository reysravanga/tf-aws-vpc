aws_profile = "default"

vpc_name = "sample_vpc"

tags = {
  "tag_key1" = "tag_value1"
  "tag_key2" = "tag_value2"
}

vpc_opts = {
  "instance_tenancy"                 = "dedicated"
  "enable_dns_support"               = "false"
  "enable_dns_hostnames"             = "true"
  "assign_generated_ipv6_cidr_block" = "true"
}
