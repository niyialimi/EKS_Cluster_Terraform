variable "cluster_name" {
  description = "The Cluster name."
}

variable "vpc_id" {
  description = "ID of the VPC. This would be fetched from the vpc module output"
}

variable "public_subnets" {
  description = "List of public subnet IDs. This would be fetched from the vpc module output"
}

variable "private_subnets" {
  description = "List of private subnet IDs. This would be fetched from the vpc module output"
}

variable "instance_types" {
  description = "Set of instance types associated with the EKS worker Node Group."
}

variable "scaling_desired_size" {
  description = "Desired number of worker nodes"
}

variable "scaling_max_size" {
  description = "Maximum number of worker nodes"
}

variable "scaling_min_size" {
  description = "Minimum number of worker nodes"
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
}


variable "public_access_cidrs" {
  description = "CIDR block range for vpc"
}