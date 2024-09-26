output "cluster_id" {
  value       = castai_gke_cluster.castai_cluster.id
  description = "CAST.AI cluster id, which can be used for accessing cluster data using API"
  sensitive   = true
}

output "castai_node_configurations" {
  description = "Map of node configurations ids by name"
  value = {
    for k, v in castai_node_configuration.this : v.name => v.id
  }
}

output "castai_node_templates" {
  description = "Map of node template by name"
  value = {
    for k, v in castai_node_template.this : v.name => v.name
  }
}

output "castai_service_account" {
  description = "Service account used by CAST AI to manage the cluster"
  value       = castai_gke_cluster.castai_cluster.cast_service_account
}
