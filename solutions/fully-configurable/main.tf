locals {
  prefix                   = var.prefix != null ? (trimspace(var.prefix) != "" ? "${var.prefix}-" : "") : ""
  code_engine_project_name = "${local.prefix}${var.code_engine_project_name}"
}

########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.4.0"
  existing_resource_group_name = var.existing_resource_group_name
}

########################################################################################################################
# Code Engine Project
########################################################################################################################

module "project" {
  source            = "terraform-ibm-modules/code-engine/ibm//modules/project"
  version           = "4.7.1"
  name              = local.code_engine_project_name
  resource_group_id = module.resource_group.resource_group_id
}
