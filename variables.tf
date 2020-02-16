#
# Variables Configuration
#

variable "aws-env" {
  description = "The environment being deployed to.  Ex: l1,l2"
  default     = "lt"
  type        = string
}

variable "account_to_iam_map" {
  type = map
  default = {
    lab = "212257324212"
    npd = "252255005674"
    prd = "136177566281"
    svc = "636232611647"
  }
}
variable "account_to_key_map" {
  type = map
  default = {
    lab = "kemper-lab-sbx-common-us-east-1"
    npd = "kemper-npd-dev-common-us-east-1"
    prd = "kemper-prd-prd-common-us-east-1"
    svc = "kemper-svc-prd-common-us-east-1"
  }
}
variable "account_to_vpc_id_map" {
  type = map
  default = {
    lab = "vpc-0bbe03a3da0c2131d"
    npd = "vpc-0fdddd0f1d6b53328"
    prd = "vpc-0fdb3d350b81e857f"
    svc = "vpc-0da1088932490b054"
  }
}
variable "account_to_vgw_id_map" {
  type = map
  default = {
    lab = "vgw-0cf2dff6eeafba753"
    npd = "vgw-0a1d99e19de88f694"
    prd = "vgw-09bce927d93e5a527"
    svc = "vgw-08a57e034059e9eb0"
  }
}
variable "workspace_to_account_map" {
  type = map
  default = {
    lab     = "lab"
    appinn  = "appinn"
    npd     = "npd"
    npddat  = "npddat"
    npddtl  = "npddtl"
    npdcnct = "npdcnct"
    npddep  = "npddep"
    dat     = "dat"
    prd     = "prd"
    prddtl  = "prddtl"
    svc     = "svc"
    prdcnct = "prdcnct"
    prddep  = "prddep"
  }
}

variable "workspace_to_size_map" {
  type = map
  default = {
    npd = "m5a.2xlarge"
    lab = "t3.medium"
    prd = "m5a.2xlarge"
    svc = "m5a.2xlarge"
  }
}

variable "workstation-external-cidr" {
  default = "10.0.0.0/16"
}

variable "workstation-cidr" {
  default = "10.14.35.190/32"
  type    = string
}

variable "default_tags" {
  type = map
  default = {
    department  = "devops"
    description = "Managed by Terraform"
  }
}

variable "cidr_block" {
  type    = string
  default = "10.15.224.0/20"
}
# variable "environment_to_keypair_map" {
#     type = map
#   default = {
#     lab
#         kemper-appinn-npd-common-us-east-1 move
#         kemper-dat-prd-common-us-east-1  delete
#         kemper-lab-npd-common-us-east-1
#         kemper-lab-sbx-common-us-east-1
#     appinn
#         kemper-appinn-sbx-common-us-east-1
#     npd
#         kemper-npd-db-common-us-east-1
#         kemper-npd-dev-common-us-east-1
#         kemper-npd-int-common-us-east-1
#         kemper-npd-npd-common-us-east-1
#     npddat
#         kemper-npddat-npd-common-us-east-1
#     npddtl
#         kemper-npddtl-npd-common-us-east-1
#         kemper-npddtl-prd-common-us-east-1
#     npdcnct
#         kemper-npdcnct-npd-common-us-east-1
#     npddep
#         kemper-npddep-npd-common-us-east-1
#     dat
#         kemper-dat-prd-common-us-east-1  delete
#         kemper-dat-prod-common-us-east-1
#     prd
#         kemper-prd-prd-common-us-east-1
#     prddtl
#         kemper-prddtl-prd-common-us-east-1
#     svc
#         kemper-svc-prd-common-us-east-1  delete
#         kemper-svc-prod-common-us-east-1
#     prdcnct
#         kemper-prdcnct-prd-common-us-east-1
#     prddep
#         kemper-prddep-prd-common-us-east-1
#
#
#   }
# }
