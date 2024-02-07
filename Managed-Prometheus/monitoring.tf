resource "azurerm_monitor_workspace" "managed_prometheus" {
  name                = local.managed_prometheus_name
  resource_group_name = module.bastion_cluster_resource_group.name
  location            = module.tag.location_primary
  tags                = module.tag.tags_without_location
}