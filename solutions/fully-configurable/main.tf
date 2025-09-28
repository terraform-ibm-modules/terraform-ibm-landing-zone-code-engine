locals {
  prefix                   = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  code_engine_project_name = "${local.prefix}${var.code_engine_project_name}"
}

########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.1"
  existing_resource_group_name = var.existing_resource_group_name
}

########################################################################################################################
# Code Engine Project
########################################################################################################################

module "project" {
  source            = "terraform-ibm-modules/code-engine/ibm//modules/project"
  version           = "4.5.13"
  name              = local.code_engine_project_name
  resource_group_id = module.resource_group.resource_group_id
}


# ########################################################################################################################
# # VPC
# ########################################################################################################################

# module "vpc" {
#   count             = 0
#   source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
#   version           = "8.2.0"
#   resource_group_id = module.resource_group.resource_group_id
#   region            = var.region
#   name              = "vpc"
#   prefix            = local.prefix
#   tags              = var.resource_tags


#   enable_vpc_flow_logs = false

#   use_public_gateways = {
#     zone-1 = true
#     zone-2 = false
#     zone-3 = false
#   }

#   subnets = {
#     zone-1 = [
#       {
#         name           = "${local.prefix}subnet"
#         cidr           = "10.10.10.0/24"
#         public_gateway = true
#         acl_name       = "${local.prefix}acl"
#       }
#     ]
#   }
#   clean_default_sg_acl = true
#   network_acls         = var.network_acls
#   # network_acls = [
#   #   {
#   #     name                         = "${local.prefix}acl"
#   #     add_ibm_cloud_internal_rules = true
#   #     add_vpc_connectivity_rules   = true
#   #     prepend_ibm_rules            = true
#   #     rules = [
#   #       {
#   #         name        = "allow-all-egress"
#   #         action      = "allow"
#   #         direction   = "outbound"
#   #         source      = "0.0.0.0/0"
#   #         destination = "0.0.0.0/0"
#   #       },
#   #       {
#   #         name        = "allow-all-ingress"
#   #         action      = "allow"
#   #         direction   = "inbound"
#   #         source      = "0.0.0.0/0"
#   #         destination = "0.0.0.0/0"
#   #       }
#   #     ]
#   #   }
#   # ]
# }

# # data "ibm_is_vpc" "vpc" {
# #   depends_on = [module.vpc] # Explicit "depends_on" here to wait for the full subnet creations
# #   identifier = module.vpc.vpc_id
# # }

# module "fleet_sg" {
#   source  = "terraform-ibm-modules/security-group/ibm"
#   version = "2.7.0"

#   security_group_name = "${local.prefix}sg"
#   # vpc_id              = module.vpc.vpc_id
#   vpc_id = var.vpc_id

#   security_group_rules = [
#     # {
#     #   name        = "allow-all-inbound-from-self"
#     #   direction   = "inbound"
#     #   remote      = "0.0.0.0/0"
#     #   # tcp         = { port_min = 0, port_max = 65535 }
#     # },
#     {
#       name      = "allow-all-outbound"
#       direction = "outbound"
#       remote    = "0.0.0.0/0"
#       # tcp         = { port_min = 0, port_max = 65535 }
#     }
#   ]
# }


# resource "ibm_is_security_group_rule" "example" {
#   group     = module.fleet_sg.security_group_id
#   direction = "inbound"
#   remote    = module.fleet_sg.security_group_id
# }

# ########################################################################################################################
# # VPE
# ########################################################################################################################

# locals {
#   cloud_services = concat(
#     var.existing_cloud_logs_crn != null ? [
#       {
#         crn                          = var.existing_cloud_logs_crn
#         vpe_name                     = "${local.prefix}icl-vpegw"
#         allow_dns_resolution_binding = false
#       }
#     ] : [],
#     var.existing_cloud_monitoring_crn != null ? [
#       {
#         crn                          = var.existing_cloud_monitoring_crn
#         vpe_name                     = "${local.prefix}sysdig-vpegw"
#         allow_dns_resolution_binding = false
#       }
#     ] : []
#   )
# }

# module "vpe_logging" {
#   count   = length(local.cloud_services) > 0 ? 1 : 0
#   source  = "terraform-ibm-modules/vpe-gateway/ibm"
#   version = "4.7.6"

#   region            = var.region
#   prefix            = "${local.prefix}log"
#   resource_group_id = module.resource_group.resource_group_id
#   vpc_id            = var.vpc_id
#   vpc_name          = var.vpc_name
#   # vpc_id            = module.vpc.vpc_id
#   # vpc_name          = module.vpc.vpc_name


#   # subnet_zone_list = [
#   #   {
#   #     id   = ([for s in module.vpc.vpc_data.subnets : s.id if s.name == "${local.prefix}-vpc-${local.prefix}subnet"])[0]
#   #     name = "${local.prefix}subnet"
#   #     zone = "zone-1"
#   #   }
#   # ]

#   subnet_zone_list   = [for subnet in local.ex_subnet_zone_list : { id = subnet.id, name = subnet.name, zone = subnet.zone, cidr = subnet.cidr }]
#   security_group_ids = [module.fleet_sg.security_group_id]

#   cloud_service_by_crn = local.cloud_services

#   service_endpoints = "private"
# }

# locals {
#   # ex_subnet_zone_list = jsondecode(var.ex_subnet_zone_list)
#   #  ex_subnet_zone_list = var.ex_subnet_zone_list

#    ex_subnet_zone_list = flatten([
#     for zone, subnets in var.ex_subnet_zone_list : [
#       for name, subnet in subnets : {
#         name = name
#         zone = zone
#         cidr = subnet.cidr
#         crn  = subnet.crn
#         id   = subnet.id
#       }
#     ]
#   ])
# }
# ########################################################################################################################
# # Cloud logs
# ########################################################################################################################

# locals {
#   icl_name        = "${local.prefix}icl"
#   cloud_logs_guid = var.existing_cloud_logs_crn != null ? module.existing_cloud_logs_crn[0].service_instance : null

# }

# module "existing_cloud_logs_crn" {
#   count   = var.existing_cloud_logs_crn != null ? 1 : 0
#   source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
#   version = "1.2.0"
#   crn     = var.existing_cloud_logs_crn
# }

# module "cloud_logs" {
#   count             = var.enable_logging ? 1 : 0
#   depends_on        = [module.cos_buckets]
#   source            = "terraform-ibm-modules/cloud-logs/ibm"
#   version           = "1.6.21"
#   resource_group_id = module.resource_group.resource_group_id
#   region            = var.region

#   # data_storage = {
#   #   logs_data = {
#   #     enabled = false
#   #     # enabled         = true
#   #     # bucket_crn      = module.cos_buckets.buckets[local.taskstore_bucket_name].bucket_crn
#   #     # bucket_endpoint = module.cos_buckets.buckets[local.taskstore_bucket_name].s3_endpoint_public
#   #   }
#   #   metrics_data = {
#   #     enabled = false
#   #   }
#   # }


#   instance_name = local.icl_name
#   # cloud_logs_provision        = true
#   # cloud_logs_plan             = "standard"
#   # cloud_logs_service_endpoints = "private"
# }

# resource "ibm_iam_service_id" "logs_service_id" {
#   count       = var.existing_cloud_logs_crn != null ? 1 : 0
#   name        = "${local.icl_name}-svc-id"
#   description = "Service ID to ingest into IBM Cloud Logs instance"
# }

# # Create IAM Service Policy granting "Sender" role to this service ID on the Cloud Logs instance
# resource "ibm_iam_service_policy" "logs_policy" {
#   count          = var.existing_cloud_logs_crn != null ? 1 : 0
#   iam_service_id = ibm_iam_service_id.logs_service_id[0].id
#   roles          = ["Sender"]
#   description    = "Policy for ServiceID to send logs to IBM Cloud Logs instance"

#   resources {
#     service              = "logs"
#     resource_instance_id = local.cloud_logs_guid # Cloud Logs instance GUID
#   }
# }


# # Create an API key for this service ID (to use for ingestion authentication)
# # resource "ibm_iam_api_key" "cloud_logs_ingestion_apikey" {
# #   name         = "logs-ingestion-key"
# #   iam_id = ibm_iam_service_id.logs_service_id[0].iam_id
# #   description  = "API key to ingest logs into IBM Cloud Logs instance ${module.cloud_logs[0].name}"
# # }

# ########################################################################################################################
# # Cloud monitoring
# ########################################################################################################################
# locals {
#   monitoring_name     = "${local.prefix}-sysdig"
#   monitoring_key_name = "${local.prefix}-sysdig-key"
# }

# module "cloud_monitoring" {
#   count             = var.enable_monitoring ? 1 : 0
#   source            = "terraform-ibm-modules/cloud-monitoring/ibm"
#   version           = "1.7.1"
#   region            = var.region
#   resource_group_id = module.resource_group.resource_group_id
#   instance_name     = local.monitoring_name
#   plan              = var.cloud_monitoring_plan
#   service_endpoints = "public-and-private"
#   # enable_platform_metrics = false
#   manager_key_name = local.monitoring_key_name
# }


# ########################################################################################################################
# # Code Engine Project
# ########################################################################################################################

# module "project" {
#   source            = "../../modules/project"
#   name              = local.project_name
#   resource_group_id = module.resource_group.resource_group_id
#   cbr_rules         = var.cbr_rules
# }

# ##############################################################################
# # Code Engine Secret
# ##############################################################################
# locals {
#   fleet_cos_secret_name      = "fleet-cos-secret"
#   fleet_registry_secret_name = "fleet-registry-secret"
#   fleet_registry_secret = {
#     (local.fleet_registry_secret_name) = {
#       format = "registry"
#       "data" = {
#         password = var.ibmcloud_api_key,
#         username = "iamapikey",
#         server   = "us.icr.io"
#       }
#     }
#   }

#   codeengine_fleet_defaults_name = "codeengine-fleet-defaults"
#   codeengine_fleet_defaults = {
#     (local.codeengine_fleet_defaults_name) = {
#       format = "generic"
#       data = merge(
#         {
#           for idx, subnet in local.ex_subnet_zone_list :
#           "pool_subnet_crn_${idx + 1}" => subnet.crn
#         },
#         {
#           pool_security_group_crns_1 = data.ibm_is_security_group.example.crn
#         },
#         var.existing_cloud_logs_crn != null ? {
#           logging_ingress_endpoint = var.cloud_logs_ingress_private_endpoint
#           logging_sender_api_key   = var.ibmcloud_api_key
#           logging_level_agent      = "debug"
#           logging_level_worker     = "debug"
#         } : {},
#         var.existing_cloud_monitoring_crn != null ? {
#           monitoring_ingestion_region = var.region
#           monitoring_ingestion_key    = var.cloud_monitoring_access_key
#         } : {}
#       )
#     }
#   }

#   secrets = merge(local.fleet_registry_secret, local.codeengine_fleet_defaults)
# }

# # creation of hmac secret is not supported by code engine provider
# # terraform_data
# resource "null_resource" "fleet_cos_secret" {
#   provisioner "local-exec" {
#     command = <<EOT
#       ibmcloud login -r "${var.region}" -g "${module.resource_group.resource_group_name}" --apikey "${var.ibmcloud_api_key}"
#       ibmcloud ce project select --name ${module.project.name}
#       ibmcloud ce secret create --name ${local.fleet_cos_secret_name} \
#       --format hmac \
#       --access-key-id ${ibm_resource_key.cos_hmac_key.credentials["cos_hmac_keys.access_key_id"]}  \
#       --secret-access-key ${ibm_resource_key.cos_hmac_key.credentials["cos_hmac_keys.secret_access_key"]}
#     EOT
#   }
# }


# data "ibm_is_security_group" "example" {
#   depends_on = [module.fleet_sg]
#   name       = "${local.prefix}sg"
# }

# # locals {
# #   identifiers = [for subnet in var.ex_subnet_zone_list : subnet.id]
# # }
# # data "ibm_is_subnet" "example" {
# #   # identifier = (([for s in module.vpc.vpc_data.subnets : s.id if s.name == "${local.prefix}-vpc-${local.prefix}subnet"])[0])
# #   identifier = local.identifiers[0]
# # }

# module "secret" {
#   source     = "../../modules/secret"
#   for_each   = nonsensitive(local.secrets)
#   project_id = module.project.project_id
#   name       = each.key
#   data       = each.value.data
#   format     = each.value.format
#   # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
#   # service_access = each.value.service_access
# }
