provider "aws" {
  region = var.AWS_REGION

  default_tags {
    tags = {
      project     = "eks_cluster"
      environment = "dev"
      managedby   = "terraform"
      owner       = "Niyi-Alimi"
    }
  }
}