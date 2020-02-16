
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "k8-cluster" {
  name = "${local.cluster-name}-cluster"

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
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.k8-cluster.name
}

resource "aws_security_group" "k8-cluster" {
  name        = "eks-${var.application}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = data.aws_vpc.k8-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.cluster-name}"
  }
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8-cluster.id
  source_security_group_id = aws_security_group.k8-node.id
  to_port                  = 443
  type                     = "ingress"
}

# TODO 
# Create a seperate rule for the jenkins nodes.  This list currently just
# contains the jenkins build and jenkins svc.  Need to confirm why jenkinsdev
# did not show this issue.  in the new rule make clear in the description
# that this is for the jenkins servers.
resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${var.workstation-cidr}", "10.103.4.16/32", "10.14.36.198/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.k8-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "k8-cluster" {
  name     = local.cluster-name
  role_arn = aws_iam_role.k8-cluster.arn

  vpc_config {
    security_group_ids      = ["${aws_security_group.k8-cluster.id}"]
    subnet_ids              = data.aws_subnet.k8-sub[*].id
    endpoint_private_access = true
    endpoint_public_access  = false
  }
  tags = {
    Name = "${local.cluster-name}"
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}
