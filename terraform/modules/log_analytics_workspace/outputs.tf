output "workspace_id" {
  description = "ID del Log Analytics Workspace (existente o creado)"
  value       = local.workspace_id
}

output "workspace_name" {
  description = "Nombre del Log Analytics Workspace (existente o creado)"
  value       = local.default_workspace_name
}
