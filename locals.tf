locals {
  # API URL used from within the cluster (by Castware) defaults to `api_url` but can be overwritten
  castware_api_url = var.castware_api_url != "" ? var.castware_api_url : var.api_url

  # Common conditional non-sensitive values that we pass to helm_releases.
  # Set up as lists so they can be concatenated.
  set_apiurl = local.castware_api_url != "" ? [{
    name  = "castai.apiURL"
    value = local.castware_api_url
  }] : []
  set_cluster_id = [{
    name  = "castai.clusterID"
    value = castai_gke_cluster.castai_cluster.id
  }]
  set_organization_id = var.organization_id != "" ? [{
    name  = "castai.organizationID"
    value = var.organization_id
  }] : []
  set_grpc_url = var.grpc_url != "" ? [{
    name  = "castai.grpcURL"
    value = var.grpc_url
  }] : []
  set_kvisor_grpc_addr = var.kvisor_grpc_addr != "" ? [{
    name  = "castai.grpcAddr"
    value = var.kvisor_grpc_addr
  }] : []
  set_pod_labels = [for k, v in var.castai_components_labels : {
    name  = "podLabels.${k}"
    value = v
  }]


  # Common conditional SENSITIVE values that we pass to helm_releases.
  # Set up as lists so they can be concatenated.
  set_sensitive_apikey = [{
    name  = "castai.apiKey"
    value = castai_gke_cluster.castai_cluster.cluster_token
  }]
}