variable "AWS_REGION" {
  description = "AWS region for the deployment"
  type        = string
  default     = "ap-southeast-2"
}

variable "az_count" {
  description = "The number of Availability zones needed."
  type        = number
  default     = 3
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_bits" {
  description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
  default     = 8
}

variable "cluster_name" {
  description = "The Cluster name."
  type        = string
  default     = "EKS_Cluster"
}

variable "instance_types" {
  description = "Set of instance types associated with the EKS worker Node Group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "scaling_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "scaling_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "scaling_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR block range for vpc"
  type        = string
  default     = "0.0.0.0/0"
}