#==== Creating IAM role for Kubernetes clusters to make calls to =====#
#==== other AWS services on your behalf to manage the resources ====#
#==== that you use with the service. ====#
resource "aws_iam_role" "eks-iam-role" {
  name               = "${var.cluster_name}-eks-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    "Name" = "${var.cluster_name}-eks-iam-role"
  }
}

#==== Attaching the EKS-Cluster policies to the eks-iam-role role. ====#
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-iam-role.name
}

#==== Create EKS Cluster ====#
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config { # Configure EKS with vpc and network settings 
    subnet_ids              = flatten([var.public_subnets[*], var.private_subnets[*]])
    security_group_ids      = ["${aws_security_group.eks_cluster.id}"]
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

#==== Creating IAM role for EKS nodes group to work with other AWS Services =====#
resource "aws_iam_role" "eks_nodes" {
  name = "${var.cluster_name}-eks-node-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = {
    "Name" = "${var.cluster_name}-eks-node-iam-role"
  }
}

#==== Attaching the required policies to the nodes-iam-role role. ====#
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

#==== Create EKS Node Groups ====#
resource "aws_eks_node_group" "worker-node-group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnets
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  tags = {
    Name = "${var.cluster_name}-node-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}