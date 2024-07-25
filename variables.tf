variable "project_id" {
  description = "The ID of the project"
  type        = string
}

variable "gke_cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "The region of the GKE cluster"
  type        = string
}

variable "service_accounts_unique_ids" {
  description = "Unique IDs of the service accounts"
  type        = list(string)
  default     = []
}

variable "wait_for_cluster_ready" {
  description = "Flag to wait for cluster readiness"
  type        = bool
  default     = false
}

variable "subnetwork_self_link" {
  description = "Self link of the subnetwork"
  type        = string
}

variable "tags" {
  description = "Tags for the node configuration"
  type        = map(string)
  default     = {}
}

variable "autoscaler_policies_json" {
  description = "Autoscaler policies in JSON format"
  type        = string
  default     = null
}

variable "node_configurations" {
  description = "Configuration for node pools"
  type        = map(object({
    disk_cpu_ratio    = number
    subnets           = list(string)
    tags              = map(string)
    max_pods_per_node = number
    disk_type         = string
    network_tags      = list(string)
  }))
  default = {}
}

variable "node_templates" {
  description = "Templates for node configurations"
  type        = map(object({
    name                       = string
    configuration_id           = string
    is_default                 = bool
    is_enabled                 = bool
    should_taint               = bool
    custom_labels              = map(string)
    custom_taints              = list(object({
      key    = string
      value  = string
      effect = string
    }))
    constraints                = object({
      on_demand                              = bool
      spot                                   = bool
      use_spot_fallbacks                     = bool
      enable_spot_diversity                  = bool
      spot_diversity_price_increase_limit_percent = number
      fallback_restore_rate_seconds          = number
      min_cpu                                = number
      max_cpu                                = number
      instance_families                      = object({
        exclude = list(string)
      })
      compute_optimized_state                = string
      storage_optimized_state                = string
    })
    custom_instances_enabled                = bool
  }))
  default = {}
}
