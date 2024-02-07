resource "kubernetes_namespace" "flux_ns_cc" {
  provider = kubernetes.control

  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

resource "kubernetes_namespace" "flux_ns_wk" {
  provider = kubernetes.workload

  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

resource "kubernetes_config_map" "flux_cm_cc" {
  provider = kubernetes.control

  metadata {
    name      = "shared-config"
    namespace = kubernetes_namespace.flux_ns_cc.metadata[0].name
  }

  data = {

    metrics_ingestion_endpoint = data.external.get_ep.result.metrics_ingestion_endpoint
  }
}

