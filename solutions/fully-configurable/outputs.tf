########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name."
  value       = module.resource_group.resource_group_name
}

output "code_engine_project_name" {
  description = "Code engine project name."
  value       = module.project.name
}

output "code_engine_project_id" {
  description = "Created code engine project identifier."
  value       = module.project.id
}

output "next_steps_text" {
  value       = "Check your Code Engine project configuration"
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Code Engine Project"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/containers/serverless/project/${var.region}/${module.project.id}/overview"
  description = "primary url"
}
