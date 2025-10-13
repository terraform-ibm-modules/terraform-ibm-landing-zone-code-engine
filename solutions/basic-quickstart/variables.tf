########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To skip using a prefix, set this value to `null` or an empty string. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "region" {
  type        = string
  description = "The region to provision all resources."
  default     = "us-south"
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources. If not provided the default resource group will be used."
  default     = null
}

variable "code_engine_project_name" {
  description = "The name of the IBM Cloud Code Engine project to be deployed. If specified, the prefix leads the project name in the <prefix>-<code_engine_project_name> format."
  type        = string
  default     = "quickstart-project"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to add to the created resources."
  default     = []
}

##############################################################################
# Code Engine Build
##############################################################################

variable "build_name" {
  description = "The name of the build."
  type        = string
  default     = "helloworld"
}

variable "source_context_dir" {
  description = "The directory in the repository that contains the buildpacks file or the Dockerfile."
  type        = string
  default     = "hello"
}

variable "source_revision" {
  description = "Commit, tag, or branch in the source repository to pull."
  type        = string
  default     = "main"
}

variable "source_url" {
  description = "The URL of the code repository. If the repository is private, you must also provide 'github_username' and 'github_password'."
  type        = string
  default     = "https://github.com/IBM/CodeEngine"
}

variable "strategy_type" {
  description = "The strategy to use for building the image."
  type        = string
  default     = "dockerfile"
}

variable "build_timeout" {
  description = "The maximum amount of time, in seconds, that can pass before the build must succeed or fail."
  type        = number
  default     = 600
}

##############################################################################
# Github Secret
##############################################################################

variable "github_password" {
  description = "GitHub personal access token used as a password when accessing private repositories."
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition     = (var.github_username == null && var.github_password == null) || (var.github_username != null && var.github_password != null)
    error_message = "Either both 'github_password' and 'github_username' must be set, or neither."
  }
}

variable "github_username" {
  description = "GitHub username used to authenticate when accessing private repositories.."
  type        = string
  default     = null
}

##############################################################################
# Code Engine App
##############################################################################

variable "app_name" {
  description = "The name of the application to be created and managed. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<app_name>` format. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-application-workloads)"
  type        = string
  default     = "my-ce-app"
}

variable "app_scale_cpu_memory" {
  description = "Define the amount of CPU and memory resources for each instance. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-mem-cpu-combo)"
  type        = string
  default     = "1 vCPU / 4 GB"
}

variable "app_image_port" {
  description = "The port which is used to connect to the port that is exposed by the container image."
  type        = number
  default     = 8080
}

variable "managed_domain_mappings" {
  description = "Define which of the following values for the system-managed domain mappings to set up for the application. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-application-workloads#optionsvisibility)"
  type        = string
  default     = "local_public"
  validation {
    condition     = var.managed_domain_mappings == null || can(regex("local_public|local_private|local", var.managed_domain_mappings))
    error_message = "Valid values are 'local_public', 'local_private', or 'local'."
  }
}

variable "app_scale_ephemeral_storage_limit" {
  description = <<EOT
The amount of ephemeral storage to set for the instance of the app.
The units for specifying ephemeral storage are Megabyte (M) or Gigabyte (G), whereas G and M are the shorthand expressions for GB and MB. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-mem-cpu-combo#unit-measurements)


The value must match regular expression '/^([0-9.]+)([eEinumkKMGTPB]*)$/'.
EOT
  type        = string
  default     = "400M"
}

##############################################################################
# Container Registry
##############################################################################

variable "container_registry_api_key" {
  description = "The API key of the container registry in the target account. If this key is not provided, the IBM Cloud API key will be used instead."
  type        = string
  sensitive   = true
  default     = null
}

variable "container_registry_namespace" {
  description = "The name of the namespace to create in IBM Cloud Container Registry for organizing container images. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<container_registry_namespace>` format."
  type        = string
  default     = "ce-cr-namespace"
}

##############################################################################
# Cloud logs
##############################################################################

variable "enable_cloud_logs" {
  description = "Whether to enable support for Cloud Logs. If enabled, a new Cloud Logs instance will be provisioned and integrated with the deployment."
  type        = bool
  nullable    = false
  default     = true
}

########################################################################################################################
# Cloud monitoring
########################################################################################################################

variable "cloud_monitoring_plan" {
  type        = string
  description = "The IBM Cloud Monitoring plan to provision. If 'None' is selected, Cloud Monitoring will not be configured."
  default     = "graduated-tier"

  validation {
    condition     = can(regex("^none$|^lite$|^graduated-tier$", var.cloud_monitoring_plan))
    error_message = "The plan value must be one of the following: none, lite and graduated-tier."
  }
}

variable "enable_platform_metrics" {
  type        = bool
  description = "Receive platform metrics in the provisioned IBM Cloud Monitoring instance. Only 1 instance in a given region can be enabled for platform metrics."
  default     = false
}
