output "data_monitor_workspace_id" {
  value       = azurerm_monitor_workspace.managed_prometheus.id
  description = "Azure Monitor workspace ID"
}