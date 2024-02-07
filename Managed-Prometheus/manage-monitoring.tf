# Random UUID for secret in keycloak for grafana client
resource "random_uuid" "grafana_random" {
}
resource "null_resource" "enable_cc_prometheus" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command     = <<EOF
     az feature register --namespace Microsoft.ContainerService --name AKS-PrometheusAddonPreview || true
     az extension add --name aks-preview || true
     az aks update --enable-azure-monitor-metrics -n ${module.control_cluster_kubernetes.aks_cluster_name} -g ${module.control_cluster_resource_group.name} --azure-monitor-workspace-resource-id ${data.terraform_remote_state.shared_services.outputs.data_monitor_workspace_id}
    EOF
    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [
    module.control_cluster_kubernetes,
    kubernetes_config_map.flux_cm_cc,
    kubernetes_namespace.flux_ns_cc,
    module.flux_bootstrap_cc
  ]
}

## Control clusters 

# create role assignment for remote-write
resource "restapi_object" "metrics_publisher_control" {
  provider = restapi.restapi_headers
  path     = "/api/${var.remote_write_role_assignment_operation}"
  data     = templatefile("${path.module}/templates/create_input.json", { OperatingEnvironment = var.remote_write_operating_environment, CloudEnvironment = var.remote_write_cloud_environment, managedIdentityObjectID = module.control_cluster_kubernetes.kubelet_managed_identity_object_id, TargetScope = data.external.get_dcrID.result.dcrID, TargetRole = var.remote_write_target_role })
}

# create role assignment for adding azure data sources
resource "restapi_object" "grafana_reader_control" {
  provider = restapi.restapi_headers
  path     = "/api/${var.remote_write_role_assignment_operation}"
  data     = templatefile("${path.module}/templates/create_input.json", { OperatingEnvironment = var.remote_write_operating_environment, CloudEnvironment = var.remote_write_cloud_environment, managedIdentityObjectID = module.control_cluster_kubernetes.kubelet_managed_identity_object_id, TargetScope = data.azurerm_subscription.current.id, TargetRole = var.grafana_subscription_target_role })
}

# create role assignment for allowing prometheus to post data to grafana
resource "restapi_object" "grafana_monitoring_data_reader_control" {
  provider = restapi.restapi_headers
  path     = "/api/${var.remote_write_role_assignment_operation}"
  data     = templatefile("${path.module}/templates/create_input.json", { OperatingEnvironment = var.remote_write_operating_environment, CloudEnvironment = var.remote_write_cloud_environment, managedIdentityObjectID = module.control_cluster_kubernetes.kubelet_managed_identity_object_id, TargetScope = data.external.get_dcrID.result.dcrID, TargetRole = var.grafana_managed_prometheus_target_role })
}

## Workload clusters 

# create role assignment for remote-write
resource "restapi_object" "metrics_publisher_workload" {
  provider = restapi.restapi_headers
  path     = "/api/${var.remote_write_role_assignment_operation}"
  data     = templatefile("${path.module}/templates/create_input.json", { OperatingEnvironment = var.remote_write_operating_environment, CloudEnvironment = var.remote_write_cloud_environment, managedIdentityObjectID = module.workload_cluster_kubernetes.kubelet_managed_identity_object_id, TargetScope = data.external.get_dcrID.result.dcrID, TargetRole = var.remote_write_target_role })
}

# create role assignment for adding azure data sources
resource "restapi_object" "grafana_reader_workload" {
  provider = restapi.restapi_headers
  path     = "/api/${var.remote_write_role_assignment_operation}"
  data     = templatefile("${path.module}/templates/create_input.json", { OperatingEnvironment = var.remote_write_operating_environment, CloudEnvironment = var.remote_write_cloud_environment, managedIdentityObjectID = module.workload_cluster_kubernetes.kubelet_managed_identity_object_id, TargetScope = data.azurerm_subscription.current.id, TargetRole = var.grafana_subscription_target_role })
}



# create role assignment for allowing prometheus to post data to grafana
resource "restapi_object" "grafana_monitoring_data_reader_workload" {
  provider = restapi.restapi_headers
  path     = "/api/${var.remote_write_role_assignment_operation}"
  data     = templatefile("${path.module}/templates/create_input.json", { OperatingEnvironment = var.remote_write_operating_environment, CloudEnvironment = var.remote_write_cloud_environment, managedIdentityObjectID = module.workload_cluster_kubernetes.kubelet_managed_identity_object_id, TargetScope = data.external.get_dcrID.result.dcrID, TargetRole = var.grafana_managed_prometheus_target_role })
}