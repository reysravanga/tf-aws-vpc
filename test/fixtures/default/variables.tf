variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "default"
}

variable "cidr" {
  description = "The cidr block for the VPC (ex. 10.x.0.0/16)"
  default     = "10.10.0.0/16"
}

variable "tags" {
  description = "The tag map for vpc"
  default     = {}
}
