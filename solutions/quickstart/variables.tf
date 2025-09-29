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
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--'). Example: prod-0205-ce. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

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
  description = "The region in which to provision all resources created by this solution."
  default     = "us-south"
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources. If not provided the default resource group will be used."
  default     = null
}

variable "code_engine_project_name" {
  description = "The name of the project to add the IBM Cloud Code Engine. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<code_engine_project_name>` format."
  type        = string
  default     = "ce-project"
}


##############################################################################
# Code Engine App
##############################################################################

variable "app_name" {
  description = "The name of the application to be created and managed. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<app_name>` format. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-application-workloads)"
  type        = string
  default     = "my-ce-app"
}

variable "app_image_reference" {
  description = "A container image can be identified by a container image reference with the following structure: registry / namespace / repository:tag. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started)"
  type        = string
  default     = "icr.io/codeengine/helloworld"
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
  description = "The API key used to authenticate with the container registry. If set, a Code Engine registry secret will be created using this value."
  type        = string
  sensitive   = true
  default     = null
}
