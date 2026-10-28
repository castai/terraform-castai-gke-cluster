mock_provider "castai" {
  mock_resource "castai_gke_cluster" {
    defaults = {
      id              = "88888888-8888-8888-8888-888888888888"
      cluster_token   = "mock-cluster-token"
      organization_id = "77777777-7777-7777-7777-777777777777"
    }
  }

  mock_resource "castai_node_configuration" {
    defaults = {
      id = "99999999-9999-9999-9999-999999999999"
    }
  }

  mock_resource "castai_node_configuration_default" {
    defaults = {
      id = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
    }
  }

  mock_resource "castai_node_template" {
    defaults = {
      id = "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
    }
  }

  mock_resource "castai_autoscaler" {
    defaults = {
      id = "cccccccc-cccc-cccc-cccc-cccccccccccc"
    }
  }

  mock_resource "castai_workload_scaling_policy" {
    defaults = {
      id = "dddddddd-dddd-dddd-dddd-dddddddddddd"
    }
  }

  mock_resource "castai_workload_custom_metrics_data_source" {
    defaults = {
      id = "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"
    }
  }
}

mock_provider "google" {}
mock_provider "helm" {}
mock_provider "null" {}

variables {
  project_id           = "test-project"
  gke_cluster_name     = "test-cluster"
  gke_cluster_location = "europe-west1"

  gke_credentials = "test-credentials-json"

  default_node_configuration = "default"
  node_configurations = {
    default = {
      name    = "default"
      subnets = ["projects/test-project/regions/europe-west1/subnetworks/test-subnet"]
    }
  }
}

run "verify_cluster_configuration_service_account_key" {
  command = plan

  assert {
    condition     = castai_gke_cluster.castai_cluster.credentials_json == "test-credentials-json"
    error_message = "Cluster registration should use the service account key credentials"
  }

  assert {
    condition     = castai_gke_cluster.castai_cluster.target_service_account_email == null
    error_message = "target_service_account_email should be null for service account key onboarding"
  }

  assert {
    condition     = castai_gke_cluster.castai_cluster.castai_service_account_email == null
    error_message = "castai_service_account_email should be null for service account key onboarding"
  }
}
