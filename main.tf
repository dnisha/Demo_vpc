locals {
  flattened_subnet_cidrs = merge([
    for az, cidr_blocks in var.subnet_cidrs : {
      for cidr_block in cidr_blocks : 
        cidr_block => az
    }
  ]...)
}

resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"
}

resource "aws_subnet" "subnet" {
  for_each          = local.flattened_subnet_cidrs
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  cidr_block        = each.key
}

variable "subnet_cidrs" {
  type = map(list(string))
  default = {
    "ap-south-1a" = ["192.168.1.0/24", "192.168.2.0/24", "192.168.0.0/24"]
    "ap-south-1b" = ["192.168.3.0/24", "192.168.4.0/24"]
  }
}

output "cidr_az_key_value" {
  value = local.flattened_subnet_cidrs
}
