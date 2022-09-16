variable "cluster_name" {
  type    = string
  default = "gke-basic"
}

variable "cluster_region" {
  type        = string
  description = "The region to create the cluster"
  default     = "europe-west1"
}


variable "cluster_zones" {
  type        = list(string)
  description = "The zones to create the cluster."
  default     = ["europe-west1-b", "europe-west1-c"]
}

variable "project_id" {
}

variable "castai_api_token" {
}