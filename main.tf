module "vpc" {
  source           = "./modules/network"
  vpc_cidr         = var.vpc_cidr
  az_count         = var.az_count
  subnet_cidr_bits = var.subnet_cidr_bits
}

module "eks_cluster" {
  source                  = "./modules/eks_cluster"
  cluster_name            = var.cluster_name
  vpc_id                  = module.vpc.vpc_id
  public_subnets          = module.vpc.public_subnets
  private_subnets         = module.vpc.private_subnets
  instance_types          = var.instance_types
  scaling_desired_size    = var.scaling_desired_size
  scaling_max_size        = var.scaling_max_size
  scaling_min_size        = var.scaling_min_size
  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access
  public_access_cidrs     = ["${var.public_access_cidrs}"]
}