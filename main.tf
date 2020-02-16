# Lets map the account to the environment
#
locals {
  workspace    = split("-", terraform.workspace)
  account      = "${lookup(var.workspace_to_account_map, element(split("-", terraform.workspace), 0), "lab")}"
  size         = "${lookup(var.workspace_to_size_map, element(split("-", terraform.workspace), 0), "select_your_workspace")}"
  cluster-name = "eks-${local.account}-${var.application}"
}
