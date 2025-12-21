locals {
  prefix = var.prefix != null ? (trimspace(var.prefix) != "" ? "${var.prefix}-" : "") : ""
}

########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.4.7"
  existing_resource_group_name = var.existing_resource_group_name
}

########################################################################################################################
# Code Engine Project
########################################################################################################################

locals {
  code_engine_project_name = "${local.prefix}${var.code_engine_project_name}"
}

module "project" {
  source            = "terraform-ibm-modules/code-engine/ibm//modules/project"
  version           = "4.7.11"
  name              = local.code_engine_project_name
  resource_group_id = module.resource_group.resource_group_id
}

##############################################################################
# Container Registry
##############################################################################

module "cr_namespace" {
  source            = "terraform-ibm-modules/container-registry/ibm"
  version           = "2.4.3"
  namespace_name    = "${local.prefix}${var.container_registry_namespace}"
  resource_group_id = module.resource_group.resource_group_id
}

module "cr_endpoint" {
  source  = "terraform-ibm-modules/container-registry/ibm//modules/endpoint"
  version = "2.4.3"
  region  = var.region
}

##############################################################################
# Code Engine Build
##############################################################################

locals {
  image_container = "${module.cr_endpoint.container_registry_endpoint_private}/${module.cr_namespace.namespace_name}"
  output_image    = "${local.image_container}/${var.build_name}"
}

module "build" {
  depends_on                 = [module.cr_secret]
  source                     = "terraform-ibm-modules/code-engine/ibm//modules/build"
  version                    = "4.7.11"
  ibmcloud_api_key           = var.ibmcloud_api_key
  project_id                 = module.project.project_id
  name                       = var.build_name
  output_image               = local.output_image
  output_secret              = local.registry_secret_name
  source_url                 = var.source_url
  strategy_type              = var.strategy_type
  source_context_dir         = var.source_context_dir
  source_revision            = var.source_revision
  region                     = var.region
  existing_resource_group_id = module.resource_group.resource_group_id
}

##############################################################################
# Code Engine Secret
##############################################################################
locals {
  registry_secret_name = "${local.prefix}registry-secret"
}

module "cr_secret" {
  source     = "terraform-ibm-modules/code-engine/ibm//modules/secret"
  version    = "4.7.11"
  project_id = module.project.project_id
  name       = local.registry_secret_name
  data = {
    password = var.ibmcloud_api_key,
    username = "iamapikey",
    server   = module.cr_endpoint.container_registry_endpoint_private
  }
  format = "registry"
}

##############################################################################
# Code Engine Apps
##############################################################################
locals {
  app_name               = "${local.prefix}${var.app_name}"
  app_scale_cpu_limit    = regex("^([0-9.]+)", var.app_scale_cpu_memory)[0]
  app_scale_memory_limit = "${regex("/ ([0-9.]+)", var.app_scale_cpu_memory)[0]}G"
}

module "app" {
  depends_on                    = [module.build]
  source                        = "terraform-ibm-modules/code-engine/ibm//modules/app"
  version                       = "4.7.11"
  name                          = local.app_name
  image_reference               = module.build.output_image
  image_secret                  = local.registry_secret_name
  project_id                    = module.project.project_id
  scale_cpu_limit               = local.app_scale_cpu_limit
  scale_ephemeral_storage_limit = var.app_scale_ephemeral_storage_limit
  scale_memory_limit            = local.app_scale_memory_limit
}

########################################################################################################################
# Cloud Object Storage
########################################################################################################################
locals {
  # needed for cloud logs
  logs_data_bucket_name    = "${local.prefix}logs-data"
  metrics_data_bucket_name = "${local.prefix}metrics-data"
}

module "cos" {
  count               = var.enable_cloud_logs ? 1 : 0
  source              = "terraform-ibm-modules/cos/ibm"
  version             = "10.7.5"
  create_cos_instance = true
  resource_group_id   = module.resource_group.resource_group_id
  region              = var.region
  cos_instance_name   = "${local.prefix}cos"
  create_cos_bucket   = false
  cos_plan            = "standard"
}

module "cos_buckets" {
  count   = var.enable_cloud_logs ? 1 : 0
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "10.7.5"

  bucket_configs = [
    {
      bucket_name            = local.logs_data_bucket_name
      kms_encryption_enabled = false
      resource_instance_id   = module.cos[0].cos_instance_crn
      region_location        = var.region
    },
    {
      bucket_name            = local.metrics_data_bucket_name
      kms_encryption_enabled = false
      resource_instance_id   = module.cos[0].cos_instance_crn
      region_location        = var.region
    }
  ]
}

########################################################################################################################
# Cloud logs
########################################################################################################################

module "cloud_logs" {
  count             = var.enable_cloud_logs ? 1 : 0
  source            = "terraform-ibm-modules/cloud-logs/ibm"
  version           = "1.10.8"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  instance_name     = "${local.prefix}-cloud-logs"
  resource_tags     = var.resource_tags
  data_storage = {
    # logs and metrics buckets must be different
    logs_data = {
      enabled         = true
      bucket_crn      = module.cos_buckets[0].buckets[local.logs_data_bucket_name].bucket_crn
      bucket_endpoint = module.cos_buckets[0].buckets[local.logs_data_bucket_name].s3_endpoint_direct
    },
    metrics_data = {
      enabled         = true
      bucket_crn      = module.cos_buckets[0].buckets[local.metrics_data_bucket_name].bucket_crn
      bucket_endpoint = module.cos_buckets[0].buckets[local.metrics_data_bucket_name].s3_endpoint_direct
    }
  }
}

########################################################################################################################
# Cloud monitoring
########################################################################################################################
locals {
  enable_cloud_monitoring = var.cloud_monitoring_plan == "none" ? false : true
  monitoring_name         = "${local.prefix}sysdig"
  monitoring_key_name     = "${local.prefix}sysdig-key"
}

module "cloud_monitoring" {
  count                   = local.enable_cloud_monitoring ? 1 : 0
  source                  = "terraform-ibm-modules/cloud-monitoring/ibm"
  version                 = "1.12.4"
  region                  = var.region
  resource_group_id       = module.resource_group.resource_group_id
  instance_name           = local.monitoring_name
  plan                    = var.cloud_monitoring_plan
  service_endpoints       = "public-and-private"
  enable_platform_metrics = "false"
  access_key_name         = local.monitoring_key_name
  resource_tags           = var.resource_tags
}
