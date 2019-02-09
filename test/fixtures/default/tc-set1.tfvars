aws_profile = "default"

vpc_name = "sample_vpc"

vpc_tags = {
  "tag_key1" = "tag_value1"
  "tag_key2" = "tag_value2"
}

vpc_opts = {
  "instance_tenancy"                 = "dedicated"
  "enable_dns_support"               = "false"
  "enable_dns_hostnames"             = "true"
  "assign_generated_ipv6_cidr_block" = "true"
}

# CIDR: 10.xyz.abc.0/24
# x= region group code2 - east/north=1, west/south=2, central=0
# y= region group code1 - us=1 , ap=2, ca=3, eu=4, sa=5
# z= region group code3 - 1, 2, 3 ... (ap-northeast-2 --> 2)
# a= publicity - 0 for private, 1 for public
# b= subnet type - infra=0, app=1, lb=2, cache=3, db=4
# c= az code - a=1, b=2, ...
# example: ap-northeast-2a public app --> 10.122.111.0/24
vpc_cidr = "10.212.0.0/16"

public_subnets = {
  "0" = ["infra", "10.212.101.0/24", "10.212.102.0/24", "10.212.103.0/24", "infra", "public"]
  "1" = ["app", "10.212.111.0/24", "10.212.112.0/24", "10.212.113.0/24", "app", ""]
  "2" = ["lb", "10.212.121.0/24", "10.212.122.0/24", "10.212.123.0/24", "", ""]
  "3" = ["cache", "10.212.131.0/24", "10.212.132.0/24", "10.212.133.0/24", "", ""]
  "4" = ["db", "10.212.141.0/24", "10.212.142.0/24", "10.212.143.0/24", "", ""]
}

private_subnets = {
  "0" = ["app", "10.212.11.0/24", "10.212.12.0/24", "10.212.13.0/24", "app", ""]
  "1" = ["lb", "10.212.21.0/24", "10.212.22.0/24", "10.212.23.0/24", "", ""]
  "2" = ["cache", "10.212.31.0/24", "10.212.32.0/24", "10.212.33.0/24", "", ""]
  "3" = ["db", "10.212.41.0/24", "10.212.42.0/24", "10.212.43.0/24", "", ""]
}

subnet_optsets = {
  "public" = {
    "map_public_ip_on_launch"         = "true"
    "assign_ipv6_address_on_creation" = "false"
  }
}

subnet_tagsets = {
  "infra" = {
    "purpose" = "infra"
  }

  "app" = {
    "purpose"  = "app"
    "tag_key1" = "tag_value1"
  }
}

cachesubnet_index = {
  "public"  = ["3"]
  "private" = ["2"]
}

dbsubnet_index = {
  "public"  = ["4"]
  "private" = ["3"]
}
