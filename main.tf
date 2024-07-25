data "google_container_cluster" "my_cluster" {
  name     = var.gke_cluster_name
  location = var.region
  project  = var.project_id
}

data "google_client_config" "default" {}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate)
  }
}




module "castai_gke_iam" {
  source  = "castai/gke-iam/castai"
  project_id = var.project_id
  gke_cluster_name = var.gke_cluster_name
  service_accounts_unique_ids = var.service_accounts_unique_ids
  depends_on = [ data.google_container_cluster.my_cluster, data.google_client_config.default ]
}



module "castai-gke-cluster" {
  source = "castai/gke-cluster/castai"
  wait_for_cluster_ready = var.wait_for_cluster_ready
  project_id           = var.project_id
  gke_cluster_name     = var.gke_cluster_name
  gke_cluster_location = var.region

  gke_credentials            = module.castai_gke_iam.private_key
  delete_nodes_on_disconnect = true
  autoscaler_policies_json   = null

  default_node_configuration = module.castai-gke-cluster.castai_node_configurations["castaidefault"]

  node_configurations = {
    castaidefault = {
      disk_cpu_ratio = 25
      subnets        = [var.subnetwork_self_link]
      tags = var.tags

      max_pods_per_node = 110
      network_tags      = ["dev"]
      disk_type         = "pd-balanced"

    }
     test_node_config = {
      disk_cpu_ratio    = 10
      subnets        = [var.subnetwork_self_link]
      tags              = {}
      max_pods_per_node = 40
      disk_type         = "pd-ssd",
      network_tags      = ["dev"]
    }   
  }
  node_templates = {
    default_by_castai = {
      name             = "default-by-castai"
      configuration_id = module.castai-gke-cluster.castai_node_configurations["castaidefault"]
      is_default       = true
      is_enabled       = true
      should_taint     = false

      constraints = {
        on_demand          = true
        spot               = true
        use_spot_fallbacks = true

        enable_spot_diversity                       = false
        spot_diversity_price_increase_limit_percent = 20
      }
    }
    spot_tmpl = {
      configuration_id = module.castai-gke-cluster.castai_node_configurations["castaidefault"]
      is_enabled       = true
      should_taint     = true

      custom_labels = {
        custom-label-key-1 = "custom-label-value-1"
        custom-label-key-2 = "custom-label-value-2"
      }

      custom_taints = [
        {
          key    = "custom-taint-key-1"
          value  = "custom-taint-value-1"
          effect = "NoSchedule"
        },
        {
          key    = "custom-taint-key-2"
          value  = "custom-taint-value-2"
          effect = "NoSchedule"
        }
      ]
      constraints = {
        fallback_restore_rate_seconds = 1800
        spot                          = true
        use_spot_fallbacks            = true
        min_cpu                       = 4
        max_cpu                       = 100
        instance_families = {
          exclude = ["e2"]
        }
        compute_optimized_state = "disabled"
        storage_optimized_state = "disabled"
      }

      custom_instances_enabled = true
    }
  }



  autoscaler_settings = {
    enabled                                 = true
    node_templates_partial_matching_enabled = false

    unschedulable_pods = {
      enabled = true

      headroom = {
        enabled           = true
        cpu_percentage    = 10
        memory_percentage = 10
      }

      headroom_spot = {
        enabled           = true
        cpu_percentage    = 10
        memory_percentage = 10
      }
    }

    node_downscaler = {
      enabled = true

      empty_nodes = {
        enabled = true
      }

      evictor = {
        aggressive_mode           = false
        cycle_interval            = "5s10s"
        dry_run                   = false
        enabled                   = true
        node_grace_period_minutes = 10
        scoped_mode               = false
      }
    }

    cluster_limits = {
      enabled = true

      cpu = {
        max_cores = 20
        min_cores = 1
      }
    }
  }
  depends_on = [data.google_container_cluster.my_cluster, data.google_client_config.default, module.castai_gke_iam ] 
}