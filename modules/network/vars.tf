variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "az_count" {
  description = "The number of Availability zones needed."
  type        = number
}

variable "subnet_cidr_bits" {
  description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
}