locals {
  #   # Common tags to be assigned to all resources
  tags = {
    "Name"                                        = "${local.cluster-name}",
    "kubernetes.io/cluster/${local.cluster-name}" = "owned",
    "Account"                                     = "${local.account}",
    "Application"                                 = "${var.application}",
    "Environment"                                 = "${local.account}",
    "AppOwner"                                    = "devops@kemperio.com",
    "Owner"                                       = "DevOps",
    "ProductCode"                                 = "P123",
    "NetworkZone"                                 = "Private",
    "Role"                                        = "app",
    "DataClassification"                          = "None",
    "DataSensitivity"                             = "None",
    "Compliance"                                  = "None",
    "GroupEntity"                                 = "None",
    "BackupProfile"                               = "bronze"
  }
}
