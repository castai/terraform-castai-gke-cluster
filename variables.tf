variable "api_url" {
  type        = string
  description = "URL of alternative CAST AI API to be used during development or testing"
  default     = "https://api.cast.ai"
}

variable "castai_api_token" {
  type        = string
  description = "Optional CAST AI API token created in console.cast.ai API Access keys section. Used only when `wait_for_cluster_ready` is set to true"
  sensitive   = true
  default     = ""
}

variable "grpc_url" {
  type        = string
  description = "gRPC endpoint used by pod-pinner"
  default     = "grpc.cast.ai:443"
}

variable "kvisor_grpc_addr" {
  type        = string
  description = "CAST AI Kvisor optimized GRPC API address"
  default     = "kvisor.prod-master.cast.ai:443" // If your cluster is in the EU region, update the grpcAddr to: https://kvisor.prod-eu.cast.ai:443
}

variable "kvisor_controller_extra_args" {
  type        = map(string)
  description = "⚠️ DEPRECATED: use kvisor_values instead (see example: https://github.com/castai/terraform-provider-castai/tree/master/examples/gke/gke_cluster_with_security/castai.tf ). Extra arguments for the kvisor controller. Optionally enable kvisor to lint Kubernetes YAML manifests, scan workload images and check if workloads pass CIS Kubernetes Benchmarks as well as NSA, WASP and PCI recommendations."
  default = {
    "kube-linter-enabled" = "true"
    "image-scan-enabled"  = "true"
    "kube-bench-enabled"  = "true"
  }
}

variable "project_id" {
  type        = string
  description = "The project id from GCP"
}

variable "gke_cluster_name" {
  type        = string
  description = "Name of the cluster to be connected to CAST AI."
}

variable "autoscaler_policies_json" {
  type        = string
  description = "Optional json object to override CAST AI cluster autoscaler policies. Deprecated, use `autoscaler_settings` instead."
  default     = null
}

variable "autoscaler_settings" {
  type        = any
  description = "Optional Autoscaler policy definitions to override current autoscaler settings"
  default     = null
}

variable "delete_nodes_on_disconnect" {
  type        = bool
  description = "Optionally delete Cast AI created nodes when the cluster is destroyed"
  default     = false
}

variable "gke_cluster_location" {
  type        = string
  description = "Location of the cluster to be connected to CAST AI. Can be region or zone for zonal clusters"

}

variable "gke_credentials" {
  type        = string
  description = "Optional GCP Service account credentials.json"
}

variable "castai_components_labels" {
  type        = map(any)
  description = "Optional additional Kubernetes labels for CAST AI pods"
  default     = {}
}

variable "node_configurations" {
  type        = any
  description = "Map of GKE node configurations to create"
  default     = {}
}

variable "default_node_configuration" {
  type        = string
  description = "ID of the default node configuration"
  default     = ""
}

variable "default_node_configuration_name" {
  type        = string
  description = "Name of the default node configuration"
  default     = ""
}

variable "node_templates" {
  type        = any
  description = "Map of node templates to create"
  default     = {}
}

variable "workload_scaling_policies" {
  type        = any
  description = "Map of workload scaling policies to create"
  default     = {}
}

variable "install_security_agent" {
  type        = bool
  default     = false
  description = "Optional flag for installation of security agent (Kvisor - https://docs.cast.ai/docs/kvisor)"
}

variable "agent_version" {
  description = "Version of castai-agent helm chart. Default latest"
  type        = string
  default     = null
}

variable "cluster_controller_version" {
  description = "Version of castai-cluster-controller helm chart. Default latest"
  type        = string
  default     = null
}

variable "evictor_version" {
  description = "Version of castai-evictor chart. Default latest"
  type        = string
  default     = null
}

variable "evictor_ext_version" {
  description = "Version of castai-evictor-ext chart. Default latest"
  type        = string
  default     = null
}

variable "pod_pinner_version" {
  description = "Version of pod-pinner helm chart. Default latest"
  type        = string
  default     = null
}

variable "spot_handler_version" {
  description = "Version of castai-spot-handler helm chart. Default latest"
  type        = string
  default     = null
}

variable "kvisor_version" {
  description = "Version of kvisor chart. If not provided, latest version will be used."
  type        = string
  default     = null
}

variable "agent_values" {
  description = "List of YAML formatted string values for agent helm chart"
  type        = list(string)
  default     = []
}

variable "spot_handler_values" {
  description = "List of YAML formatted string values for spot-handler helm chart"
  type        = list(string)
  default     = []
}

variable "cluster_controller_values" {
  description = "List of YAML formatted string values for cluster-controller helm chart"
  type        = list(string)
  default     = []
}

variable "evictor_values" {
  description = "List of YAML formatted string values for evictor helm chart"
  type        = list(string)
  default     = []
}

variable "evictor_ext_values" {
  description = "List of YAML formatted string with evictor-ext values"
  type        = list(string)
  default     = []
}

variable "pod_pinner_values" {
  description = "List of YAML formatted string values for agent helm chart"
  type        = list(string)
  default     = []
}

variable "kvisor_values" {
  description = "List of YAML formatted string values for kvisor helm chart, see example: https://github.com/castai/terraform-provider-castai/tree/master/examples/gke/gke_cluster_with_security/castai.tf"
  type        = list(string)
  default     = []
}

variable "self_managed" {
  type        = bool
  default     = false
  description = "Whether CAST AI components' upgrades are managed by a customer; by default upgrades are managed CAST AI central system."
}

variable "wait_for_cluster_ready" {
  type        = bool
  description = "Wait for cluster to be ready before finishing the module execution, this option requires `castai_api_token` to be set"
  default     = false
}

variable "install_workload_autoscaler" {
  type        = bool
  default     = false
  description = "Optional flag for installation of workload autoscaler (https://docs.cast.ai/docs/workload-autoscaling-configuration)"
}

variable "workload_autoscaler_version" {
  description = "Version of castai-workload-autoscaler helm chart. Default latest"
  type        = string
  default     = null
}

variable "workload_autoscaler_values" {
  description = "List of YAML formatted string with cluster-workload-autoscaler values"
  type        = list(string)
  default     = []
}

variable "install_cloud_proxy" {
  description = "Optional flag for installation of castai-cloud-proxy"
  type        = bool
  default     = false
}

variable "cloud_proxy_version" {
  description = "Version of the castai-cloud-proxy Helm chart. Defaults to latest."
  type        = string
  default     = null
}

variable "cloud_proxy_values" {
  description = "List of YAML formatted strings with castai-cloud-proxy values"
  type        = list(string)
  default     = []
}

variable "cloud_proxy_grpc_url_override" {
  description = "Override for the castai-cloud-proxy gRPC URL"
  type        = string
  default     = null
}

variable "install_pod_mutator" {
  description = "Optional flag for installation of pod mutator"
  type        = bool
  default     = false
}

variable "pod_mutator_version" {
  description = "Version of castai-pod-mutator helm chart. Default latest"
  type        = string
  default     = null
}

variable "pod_mutator_values" {
  description = "List of YAML formatted string values for pod-mutator helm chart"
  type        = list(string)
  default     = []
}

variable "organization_id" {
  description = "DEPRECATED (required only for pod mutator v0.0.25 and older): CAST AI Organization ID"
  type        = string
  default     = ""
}