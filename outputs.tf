#
# Outputs
#

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
    name: aws-auth
    namespace: kube-system
data:
    mapUsers: |
      - groups:
        - system:masters
        userarn: arn:aws:iam::${lookup(var.account_to_iam_map, element(split("-", terraform.workspace), 0))}:user/jenkinsbuild
        username: jenkinsbuild
    mapRoles: |
      - rolearn: ${aws_iam_role.k8-node.arn}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
      - rolearn: arn:aws:iam::${lookup(var.account_to_iam_map, element(split("-", terraform.workspace), 0))}:role/${local.account}-us-east-1-EKSAdminRole
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:masters
      - rolearn: arn:aws:iam::${lookup(var.account_to_iam_map, element(split("-", terraform.workspace), 0))}:role/role-npd-kjmp-d0
        username: i-04330c97ce9eda69c
        groups:
          - system:masters
CONFIGMAPAWSAUTH

  # Removed from above config_map_aws_auth
  # - rolearn: arn:aws:iam::212257324212:assumed-role/lab-us-east-1-EKSAdminRole/i-04330c97ce9eda69c
  #     username: i-04330c97ce9eda69c
  #     groups:
  #     - system:masters
  alb-ingress-controller = <<ALBINGRESSCONTROLLER

# Application Load Balancer (ALB) Ingress Controller Deployment Manifest.
# This manifest details sensible defaults for deploying an ALB Ingress Controller.
# GitHub: https://github.com/kubernetes-sigs/aws-alb-ingress-controller
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: alb-ingress-controller
  name: alb-ingress-controller
  # Namespace the ALB Ingress Controller should run in. Does not impact which
  # namespaces it's able to resolve ingress resource for. For limiting ingress
  # namespace scope, see --watch-namespace.
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: alb-ingress-controller
  template:
    metadata:
      labels:
        app.kubernetes.io/name: alb-ingress-controller
    spec:
      containers:
        - name: alb-ingress-controller
          args:
            # Limit the namespace where this ALB Ingress Controller deployment will
            # resolve ingress resources. If left commented, all namespaces are used.
            # - --watch-namespace=your-k8s-namespace

            # Setting the ingress-class flag below ensures that only ingress resources with the
            # annotation kubernetes.io/ingress.class: "alb" are respected by the controller. You may
            # choose any class you'd like for this controller to respect.
            - --ingress-class=alb

            # REQUIRED
            # Name of your cluster. Used when naming resources created
            # by the ALB Ingress Controller, providing distinction between
            # clusters.
            - --cluster-name=${local.cluster-name}

            # AWS VPC ID this ingress controller will use to create AWS resources.
            # If unspecified, it will be discovered from ec2metadata.
            # - --aws-vpc-id=vpc-xxxxxx

            # AWS region this ingress controller will operate in.
            # If unspecified, it will be discovered from ec2metadata.
            # List of regions: http://docs.aws.amazon.com/general/latest/gr/rande.html#vpc_region
            # - --aws-region=us-west-1

            # Enables logging on all outbound requests sent to the AWS API.
            # If logging is desired, set to true.
            # - ---aws-api-debug
            # Maximum number of times to retry the aws calls.
            # defaults to 10.
            # - --aws-max-retries=10
          # env:
            # AWS key id for authenticating with the AWS API.
            # This is only here for examples. It's recommended you instead use
            # a project like kube2iam for granting access.
            #- name: AWS_ACCESS_KEY_ID
            #  value: KEYVALUE

            # AWS key secret for authenticating with the AWS API.
            # This is only here for examples. It's recommended you instead use
            # a project like kube2iam for granting access.
            #- name: AWS_SECRET_ACCESS_KEY
            #  value: SECRETVALUE
          # Repository location of the ALB Ingress Controller.
          image: virt-docker.artifactory.kemperi.com/amazon/aws-alb-ingress-controller:v1.1.2
      serviceAccountName: alb-ingress-controller

ALBINGRESSCONTROLLER

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.k8-cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.k8-cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${local.cluster-name}"
KUBECONFIG
}

output "alb-ingress-controller" {
  value = "${local.alb-ingress-controller}"
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}
output "account" {
  value = "${local.account}"
}
output "workspace" {
  value = "${local.workspace}"
}
output "vpc_id" {
  value = "${data.aws_vpc.k8-vpc.id}"
}
output "subnet_ids" {
  value = "${data.aws_subnet.k8-sub.*.id}"
}
output "subnet_cidr_blocks" {
  value = "${data.aws_subnet.k8-sub.*.cidr_block}"
}
output "availability_zones" {
  value = "${data.aws_availability_zones.available}"
}
output "current_region" {
  value = "${data.aws_region.current}"
}
