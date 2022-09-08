# ==== EKS Cluster Security Group ====#
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}_Public_sg"
  description = "Security group for Control Plane to allow network traffic to and from the EKS Cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}_Public_sg"
  }
}

resource "aws_security_group_rule" "cluster_inbound_https" {
  type                     = "ingress"
  description              = "Allow Inbound HTTPS Traffic to Control Plane"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "cluster_inbound_http" {
  type                     = "ingress"
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "cluster_outbound" {
  type              = "egress"
  description       = "Allow cluster API Server to communicate with the worker nodes"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
}

#==== Nodes Security Group ====#
resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}_Nodes_sg"
  description = "Security group to Allow woker nodes to communicate with each other"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}_Nodes_sg"
  }
}

resource "aws_security_group_rule" "nodes_inbound_self" {
  type                     = "ingress"
  description              = "Allow woker nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodes_inbound_cluster" {
  type                     = "ingress"
  description              = "Allow worker nodes to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "node_outbound" {
  type              = "egress"
  description       = "Allow nodes to communicate outside the cluster"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nodes.id
  cidr_blocks       = ["0.0.0.0/0"]
}