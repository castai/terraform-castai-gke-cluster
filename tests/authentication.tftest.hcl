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

  mock_resource "castai_autoscaler_policies" {
    defaults = {
      id = "cccccccc-cccc-cccc-cccc-cccccccccccc"
    }
  }

  mock_resource "castai_evictor" {
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

  default_node_configuration = "default"
  node_configurations = {
    default = {
      name    = "default"
      subnets = ["projects/test-project/regions/europe-west1/subnetworks/test-subnet"]
    }
  }
}

run "impersonation_emails_must_be_set_together" {
  command = plan

  variables {
    castai_service_account_email = "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
  }

  expect_failures = [
    var.target_service_account_email,
  ]
}

run "gke_credentials_and_impersonation_emails_conflict" {
  command = plan

  variables {
    gke_credentials              = "test-credentials-json"
    target_service_account_email = "castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
    castai_service_account_email = "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
  }

  expect_failures = [
    var.castai_service_account_email,
  ]
}

run "onboarding_method_required" {
  command = plan

  expect_failures = [
    var.castai_service_account_email,
  ]
}

run "impersonation_onboarding" {
  command = plan

  variables {
    target_service_account_email = "castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
    castai_service_account_email = "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
  }

  assert {
    condition     = castai_gke_cluster.castai_cluster.credentials_json == null
    error_message = "credentials_json should be null for impersonation onboarding"
  }

  assert {
    condition     = castai_gke_cluster.castai_cluster.target_service_account_email == "castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
    error_message = "target_service_account_email should be passed to the cluster registration"
  }

  assert {
    condition     = castai_gke_cluster.castai_cluster.castai_service_account_email == "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
    error_message = "castai_service_account_email should be passed to the cluster registration"
  }
}

run "separate_autoscaler_policies_and_evictor_settings" {
  command = plan

  variables {
    target_service_account_email = "castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
    castai_service_account_email = "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
    autoscaler_settings = {
      enabled     = true
      scoped_mode = true
      unschedulable_pods = {
        enabled                            = true
        partial_template_matching_enabled = true
      }
      node_downscaler = {
        empty_nodes_enabled = true
        empty_nodes_delay   = "120s"
      }
    }
    evictor_settings = {
      enabled = true
      dry_run = true
    }
  }

  assert {
    condition     = castai_autoscaler_policies.castai_autoscaler_policies[0].scoped_mode == true
    error_message = "Autoscaler policies should use the V2 scoped_mode field"
  }

  assert {
    condition     = castai_autoscaler_policies.castai_autoscaler_policies[0].unschedulable_pods[0].partial_template_matching_enabled == true
    error_message = "Partial template matching should be nested under unschedulable_pods"
  }

  assert {
    condition     = castai_autoscaler_policies.castai_autoscaler_policies[0].node_downscaler[0].empty_nodes_delay == "120s"
    error_message = "Node downscaler should use the V2 empty_nodes_delay duration"
  }

  assert {
    condition     = castai_evictor.castai_evictor[0].enabled == true && castai_evictor.castai_evictor[0].dry_run == true
    error_message = "Evictor settings should be mapped independently from autoscaler policies"
  }
}
