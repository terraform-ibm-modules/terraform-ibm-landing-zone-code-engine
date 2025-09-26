# Landing Zone Code Engine Fleets Deployable Architecture

Unlike the [extension-type](../tf-extension-da/) deployable architecture, this solution is "fullstack" and has no dependencies on other deployable architectures. A fullstack-type deployable architecture deploys and end-to-end solution.

:information_source: **Tip:** This `fullstack` install type is different from a [deployable architecture stack](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understand-module-da#what-is-da), which is an architecture built of two or more deployable architectures that are often linked with references and deployed in a particular sequence.

You specify the type of deployable architecture in the `ibm_catalog.json` file.

- The `install_type` for this deployable architecture is set to `fullstack`.

This solution provisions the following resources:
- **Resource Group**:
    - Creates a new resource group, unless an existing one is provided.
- **Cloud Object Storage (COS)**:
    - A global Cloud Object Storage instance.
    - Three buckets:
        - `taskstore`
        - `input`
        - `output`
    - Each bucket includes lifecycle configurations.
- **Persistent Data Stores**:
    - `fleet-task-store`
    - `fleet-input-store`
    - `fleet-output-store`
- **Virtual Private Cloud (VPC)**:
    - Spans three availability zones.
    - Configured with:
    - ACL rules allowing all ingress and egress traffic.
    - A security group allowing all outbound traffic.
- **Virtual Private Endpoint (VPE)**:
    - Includes a public gateway.
- **Cloud Engine Configuration**:
    - Project setup and secret management.
- **Optional Services**:
    - Cloud logging.
    - Cloud monitoring.

![cos-replication](../../reference-architectures/deployment-architecture-fleets.svg)

:exclamation: This solution is not intended to be called by one or more other modules since they contain provider configurations, meaning they are not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.3.5 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.81.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_logs"></a> [cloud\_logs](#module\_cloud\_logs) | terraform-ibm-modules/cloud-logs/ibm | 1.6.21 |
| <a name="module_cloud_monitoring"></a> [cloud\_monitoring](#module\_cloud\_monitoring) | terraform-ibm-modules/cloud-monitoring/ibm | 1.7.1 |
| <a name="module_cos"></a> [cos](#module\_cos) | terraform-ibm-modules/cos/ibm | 10.2.13 |
| <a name="module_cos_buckets"></a> [cos\_buckets](#module\_cos\_buckets) | terraform-ibm-modules/cos/ibm//modules/buckets | 10.2.13 |
| <a name="module_fleet_sg"></a> [fleet\_sg](#module\_fleet\_sg) | terraform-ibm-modules/security-group/ibm | 2.7.0 |
| <a name="module_project"></a> [project](#module\_project) | terraform-ibm-modules/code-engine/ibm//modules/project | 4.5.13 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.3.0 |
| <a name="module_secret"></a> [secret](#module\_secret) | terraform-ibm-modules/code-engine/ibm//modules/secret | 4.5.13 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-ibm-modules/landing-zone-vpc/ibm | 8.2.0 |
| <a name="module_vpe_logging"></a> [vpe\_logging](#module\_vpe\_logging) | terraform-ibm-modules/vpe-gateway/ibm | 4.7.6 |

### Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket_lifecycle_configuration.output_bucket_lifecycle](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.81.1/docs/resources/cos_bucket_lifecycle_configuration) | resource |
| [ibm_iam_authorization_policy.codeengine_to_cos](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.81.1/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_service_id.logs_service_id](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.81.1/docs/resources/iam_service_id) | resource |
| [ibm_iam_service_policy.logs_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.81.1/docs/resources/iam_service_policy) | resource |
| [ibm_is_security_group_rule.example](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.81.1/docs/resources/is_security_group_rule) | resource |
| [terraform_data.create_cos_secret](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.create_pds](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [external_external.container_registry_region](https://registry.terraform.io/providers/hashicorp/external/2.3.5/docs/data-sources/external) | data source |
| [ibm_is_security_group.example](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.81.1/docs/data-sources/is_security_group) | data source |
| [ibm_is_vpc.vpc](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.81.1/docs/data-sources/is_vpc) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_monitoring_plan"></a> [cloud\_monitoring\_plan](#input\_cloud\_monitoring\_plan) | The IBM Cloud Monitoring plan to provision. Available: lite, graduated-tier and graduated-tier-sysdig-secure-plus-monitor (available in region eu-fr2 only) | `string` | `"graduated-tier"` | no |
| <a name="input_code_engine_project_name"></a> [code\_engine\_project\_name](#input\_code\_engine\_project\_name) | The name of the project to add the IBM Cloud Code Engine. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<project_name>` format. | `string` | `"fleets-project"` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | The plan to use when Object Storage instances are created. Possible values are `standard` or `cos-one-rate-plan`. Required if `create_cos_instance` is set to `true`. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-provision). | `string` | `"standard"` | no |
| <a name="input_enable_cloud_logs"></a> [enable\_cloud\_logs](#input\_enable\_cloud\_logs) | Whether to add support for cloud logs. | `bool` | `true` | no |
| <a name="input_enable_platform_metrics"></a> [enable\_platform\_metrics](#input\_enable\_platform\_metrics) | Receive platform metrics in the provisioned IBM Cloud Monitoring instance. Only 1 instance in a given region can be enabled for platform metrics. | `bool` | `false` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group to provision the resources. If not provided the default resource group will be used. | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--'). Example: prod-0205-vpc. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md). | `string` | `"quickstart"` | no |
| <a name="input_provider_visibility"></a> [provider\_visibility](#input\_provider\_visibility) | Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints). | `string` | `"private"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which to provision all resources created by this solution. | `string` | `"us-south"` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to add to the created resources. | `list(string)` | `[]` | no |
| <a name="input_vpc_zones"></a> [vpc\_zones](#input\_vpc\_zones) | Number of VPC zones to use (must be 1, 2, or 3) | `number` | `3` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_logs_crn"></a> [cloud\_logs\_crn](#output\_cloud\_logs\_crn) | CRN of the cloud logs instance. |
| <a name="output_cloud_logs_name"></a> [cloud\_logs\_name](#output\_cloud\_logs\_name) | Name of the cloud logs instance. |
| <a name="output_cloud_monitoring_crn"></a> [cloud\_monitoring\_crn](#output\_cloud\_monitoring\_crn) | CRN of the cloud monitoring instance. |
| <a name="output_cloud_monitoring_name"></a> [cloud\_monitoring\_name](#output\_cloud\_monitoring\_name) | Name of the cloud monitoring instance. |
| <a name="output_cloud_object_storage_crn"></a> [cloud\_object\_storage\_crn](#output\_cloud\_object\_storage\_crn) | Name of the cloud object storage instance. |
| <a name="output_code_engine_project_id"></a> [code\_engine\_project\_id](#output\_code\_engine\_project\_id) | Id of the code engine project. |
| <a name="output_code_engine_project_name"></a> [code\_engine\_project\_name](#output\_code\_engine\_project\_name) | Name of the code engine project. |
| <a name="output_next_step_primary_label"></a> [next\_step\_primary\_label](#output\_next\_step\_primary\_label) | Primary label |
| <a name="output_next_step_primary_url"></a> [next\_step\_primary\_url](#output\_next\_step\_primary\_url) | primary url |
| <a name="output_next_step_secondary_label"></a> [next\_step\_secondary\_label](#output\_next\_step\_secondary\_label) | Secondary label |
| <a name="output_next_step_secondary_url"></a> [next\_step\_secondary\_url](#output\_next\_step\_secondary\_url) | Secondary url |
| <a name="output_next_steps_text"></a> [next\_steps\_text](#output\_next\_steps\_text) | Next steps text |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group. |
| <a name="output_tasks_state_store_name"></a> [tasks\_state\_store\_name](#output\_tasks\_state\_store\_name) | Name of the task state store. |
| <a name="output_vpc_crn"></a> [vpc\_crn](#output\_vpc\_crn) | CRN of the VPC. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | Name of the VPC. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
