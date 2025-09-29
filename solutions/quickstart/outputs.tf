########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "The name of the resource group."
  value       = module.resource_group.resource_group_name
}

output "code_engine_project_name" {
  description = "The name of the created code engine project."
  value       = module.project.name
}

output "code_engine_project_id" {
  description = "The ID of the created code engine project."
  value       = module.project.id
}

output "app_endpoint" {
  description = "The endpoint URL of the deployed application."
  value       = module.app.endpoint
}

output "app_name" {
  description = "The name of the deployed application."
  value       = module.app.name
}

output "next_steps_text" {
  value       = "Now, check your Code Engine project configuration."
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

output "next_step_secondary_label" {
  value       = "Open the application"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = module.app.endpoint
  description = "Secondary url"
}
