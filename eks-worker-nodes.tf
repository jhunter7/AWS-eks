
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances


resource "aws_iam_role" "k8-node" {
  name               = "${local.cluster-name}-node"
  description        = "IAM role allowing Kubernetes actions to access other AWS services"
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
}

# resource "aws_iam_policy" "k8-node-kms-key" {
#   name               = "${local.cluster-name}-node-kms-key"
#   description        = "IAM role allowing Kubernetes actions to access other AWS services"
#   policy = <<POLICY
# {
#   "Sid": "Allow use of the key",
#   "Effect": "Allow",
#   "Principal": {
#     "AWS": [
#       "arn:aws:iam::212257324212:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling_CMK"
#     ]
#   },
#   "Action": [
#     "kms:Encrypt",
#     "kms:Decrypt",
#     "kms:ReEncrypt*",
#     "kms:GenerateDataKey*",
#     "kms:DescribeKey"
#   ],
#   "Resource": "*"
# }
# POLICY
# }
#
#
# resource "aws_iam_policy" "k8-node-kms-persistent" {
#   name               = "${local.cluster-name}-node-kms-persistent"
#   description        = "IAM role allowing Kubernetes actions to access other AWS services"
#   policy = <<POLICY
# {
#   "Sid": "Allow attachment of persistent resources",
#   "Effect": "Allow",
#   "Principal": {
#     "AWS": [
#       "arn:aws:iam::212257324212:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling_CMK"
#     ]
#   },
#   "Action": [
#     "kms:CreateGrant"
#   ],
#   "Resource": "*",
#   "Condition": {
#     "Bool": {
#       "kms:GrantIsForAWSResource": true
#     }
#   }
# }
# POLICY
# }

resource "aws_iam_role_policy_attachment" "k8-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8-node.name
}

resource "aws_iam_role_policy_attachment" "k8-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8-node.name
}

resource "aws_iam_policy" "KMSAutoscalePolicy" {
  name        = "KMSAutoscalePolicy-${local.cluster-name}"
  path        = "/"
  description = "KMS Autoscale Policy to decrypt volumes"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt",
                "kms:RevokeGrant",
                "kms:GenerateDataKey",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:ReEncrypt*",
                "kms:DescribeKey",
                "kms:CreateGrant",
                "kms:ListGrants"
              ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "KMSAutoscaleNodePolicy" {
  role       = aws_iam_role.k8-node.name
  policy_arn = aws_iam_policy.KMSAutoscalePolicy.arn
}

resource "aws_iam_role_policy_attachment" "KMSAutoscaleClusterPolicy" {
  role       = aws_iam_role.k8-cluster.name
  policy_arn = aws_iam_policy.KMSAutoscalePolicy.arn
}

# ALBIngress Controller IAM Policy
resource "aws_iam_policy" "ALBIngressControllerIAMPolicy" {
  name        = "ALBIngressControllerIAMPolicy-${local.cluster-name}"
  path        = "/"
  description = "ALBIngressControllerIAMPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "acm:GetCertificate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVpcs",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:RemoveTags",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:SetWebACL"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "iam:GetServerCertificate",
                "iam:ListServerCertificates"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "waf-regional:GetWebACLForResource",
                "waf-regional:GetWebACL",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",
                "tag:TagResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "waf:GetWebACL"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "k8-node-AmazonEKS_ALBIAMIngressControllerIAM_Policy" {
  policy_arn = aws_iam_policy.ALBIngressControllerIAMPolicy.id
  role       = aws_iam_role.k8-node.name
}

resource "aws_iam_role_policy_attachment" "k8-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8-node.name
}

resource "aws_iam_instance_profile" "k8-node" {
  name = "eks-${var.application}-NodeInstanceProfile"
  role = aws_iam_role.k8-node.name
}

resource "aws_security_group" "k8-node" {
  name        = "eks-${var.application}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = data.aws_vpc.k8-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    map(
      "Name", "eks-${var.application}-node",
      "kubernetes.io/cluster/${local.cluster-name}", "owned",
  ))
}

resource "aws_security_group_rule" "k8-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.k8-node.id
  source_security_group_id = aws_security_group.k8-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "k8-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.k8-node.id
  source_security_group_id = aws_security_group.k8-cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

data "aws_ami" "k8-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.k8-cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  k8-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.k8-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.k8-cluster.certificate_authority.0.data}' '${local.cluster-name}'
USERDATA

  keypair-name = "${var.account_to_key_map[local.account]}"
}
output "k8-node-userdata" {
  value = "${local.k8-node-userdata}"
}
resource "aws_launch_configuration" "k8-launch-config" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.k8-node.name
  image_id                    = data.aws_ami.k8-worker.id
  instance_type               = local.size
  name_prefix                 = local.cluster-name
  security_groups             = ["${aws_security_group.k8-node.id}"]
  user_data_base64            = base64encode(local.k8-node-userdata)
  key_name                    = local.keypair-name
  # enable_monitoring           = true
  # ebs_optimized               = true

  # root_block_device {
  #   encrypted = true
  # }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "k8-autoscale" {
  name = local.cluster-name

  desired_capacity          = var.node_count
  max_size                  = 6
  min_size                  = 0
  wait_for_capacity_timeout = "3m"

  health_check_type = "EC2"
  # normally set this to 300
  health_check_grace_period = "120"

  launch_configuration = aws_launch_configuration.k8-launch-config.id

  vpc_zone_identifier = data.aws_subnet.k8-sub[*].id

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = local.cluster-name
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${local.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "Account"
    value               = local.account
    propagate_at_launch = true
  }
  tag {
    key                 = "Application"
    value               = var.application
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = local.account
    propagate_at_launch = true
  }
  tag {
    key                 = "AppOwner"
    value               = "devops@kemperio.com"
    propagate_at_launch = true
  }
  tag {
    key                 = "Owner"
    value               = "DevOps"
    propagate_at_launch = true
  }
  tag {
    key                 = "ProductCode"
    value               = "P123"
    propagate_at_launch = true
  }
  tag {
    key                 = "NetworkZone"
    value               = "Private"
    propagate_at_launch = true
  }
  tag {
    key                 = "Role"
    value               = "app"
    propagate_at_launch = true
  }
  tag {
    key                 = "DataClassification"
    value               = "None"
    propagate_at_launch = true
  }
  tag {
    key                 = "DataSensitivity"
    value               = "None"
    propagate_at_launch = true
  }
  tag {
    key                 = "Compliance"
    value               = "None"
    propagate_at_launch = true
  }
  tag {
    key                 = "GroupEntity"
    value               = "None"
    propagate_at_launch = true
  }
  tag {
    key                 = "BackupProfile"
    value               = "bronze"
    propagate_at_launch = true
  }
}
