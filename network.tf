#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#
data "aws_vpc" "k8-vpc" {
  id = "${var.account_to_vpc_id_map[local.account]}"
}

data "aws_subnet_ids" "k8-sub" {
  vpc_id = "${var.account_to_vpc_id_map[local.account]}"
  filter {
    name   = "tag:Name"
    values = ["${local.account}-${data.aws_region.current.name}-pri-eksaz*"]
  }
}
output "aws_subnet_ids" {
  value = data.aws_subnet_ids.k8-sub.ids
}
locals {
  subnet_ids_string = join(",", data.aws_subnet_ids.k8-sub.ids)
  subnet_ids_list   = split(",", local.subnet_ids_string)
}
data "aws_subnet" "k8-sub" {
  count = "${length(data.aws_subnet_ids.k8-sub.ids)}"
  id    = "${local.subnet_ids_list[count.index]}"
}
