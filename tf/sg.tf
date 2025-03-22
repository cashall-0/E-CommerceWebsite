# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

# Security Group for Worker Nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}

# Allow traffic between control plane and worker nodes
resource "aws_security_group_rule" "cluster_to_nodes" {
  description              = "Allow cluster to communicate with worker nodes"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_to_cluster" {
  description              = "Allow worker nodes to communicate with the cluster"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow worker nodes to communicate with each other
resource "aws_security_group_rule" "nodes_self" {
  description       = "Allow worker nodes to communicate with each other"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_nodes_sg.id
  self              = true
  to_port           = 65535
  type              = "ingress"
}