variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "default"
}

# copy from module variables.tf

variable "vpc_name" {
  description = "The vpc name"
  type        = "string"
}

variable "cidr" {
  description = "The cidr block for the VPC (ex. 10.x.0.0/16)"
  type        = "string"
  default     = "10.10.0.0/16"
}

variable "tags" {
  description = "The tag map for vpc"
  type        = "map"
  default     = {}
}

variable "vpc_opts" {
  description = "The additional options for the VPC resource"
  type        = "map"
  default     = {}
}
