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
        enabled                           = true
        partial_template_matching_enabled = true
      }
      node_downscaler = {
        empty_nodes_enabled = true
        empty_nodes_delay   = "120s"
      }
    }
    evictor_settings = {
      enabled                                = true
      dry_run                                = true
      aggressive_mode                        = true
      scoped_mode                            = true
      cycle_interval                         = "5m"
      node_grace_period_minutes              = 10
      pod_eviction_failure_back_off_interval = "10s"
      ignore_pod_disruption_budgets          = true
      arm64_supported                        = true
      drain_timeout                          = "10m"
      drain_rollback_timeout                 = "5m"
      emit_node_related_pod_events           = true
      force_disable_karpenter_mode           = true
      force_disable_live_migration           = true
      force_disable_pod_mutations            = true
      force_disable_woop                     = true
      max_target_nodes_per_cycle             = 10
      min_target_nodes_per_cycle             = 1
      pricing_awareness_enabled              = true
      soft_tainting                          = true
      target_node_percentage                 = 50
      windows                                = true
      pricing_model = [{
        base_cpu_cost = "0.03"
        base_mem_cost = "0.004"
        spot_discount = "0.5"
      }]
      timeouts = {
        create = "4m"
        update = "4m"
      }
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

  assert {
    condition     = castai_evictor.castai_evictor[0].arm64_supported == true && castai_evictor.castai_evictor[0].soft_tainting == true && castai_evictor.castai_evictor[0].windows == true
    error_message = "Boolean evictor fields should be mapped"
  }

  assert {
    condition     = castai_evictor.castai_evictor[0].max_target_nodes_per_cycle == 10 && castai_evictor.castai_evictor[0].target_node_percentage == 50
    error_message = "Numeric evictor fields should be mapped"
  }

  assert {
    condition     = castai_evictor.castai_evictor[0].drain_timeout == "10m" && castai_evictor.castai_evictor[0].drain_rollback_timeout == "5m"
    error_message = "Duration evictor fields should be mapped"
  }

  assert {
    condition     = castai_evictor.castai_evictor[0].pricing_model[0].base_cpu_cost == "0.03" && castai_evictor.castai_evictor[0].pricing_model[0].spot_discount == "0.5"
    error_message = "pricing_model should be mapped"
  }

  assert {
    condition     = castai_evictor.castai_evictor[0].timeouts.create == "4m"
    error_message = "timeouts should be mapped"
  }

  assert {
    condition     = anytrue([for s in helm_release.castai_evictor[0].set : s.name == "evictorEnabled" && s.value == "true"])
    error_message = "Managed mode should pass evictorEnabled from evictor_settings.enabled"
  }
}

run "null_autoscaler_and_evictor_settings" {
  command = plan

  variables {
    target_service_account_email = "castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
    castai_service_account_email = "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
  }

  assert {
    condition     = length(castai_autoscaler_policies.castai_autoscaler_policies) == 0
    error_message = "Null autoscaler settings should not create a policies resource"
  }

  assert {
    condition     = length(castai_evictor.castai_evictor) == 0
    error_message = "Null evictor settings should not create an evictor resource"
  }

  assert {
    condition     = anytrue([for s in helm_release.castai_evictor[0].set : s.name == "evictorEnabled" && s.value == "false"])
    error_message = "Null evictor settings should pass evictorEnabled=false"
  }
}

run "explicitly_disabled_evictor" {
  command = plan

  variables {
    target_service_account_email = "castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
    castai_service_account_email = "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
    evictor_settings = {
      enabled = false
    }
  }

  assert {
    condition     = castai_evictor.castai_evictor[0].enabled == false
    error_message = "Explicit false should create a disabled evictor policy"
  }

  assert {
    condition     = anytrue([for s in helm_release.castai_evictor[0].set : s.name == "evictorEnabled" && s.value == "false"])
    error_message = "Explicit false should pass evictorEnabled=false"
  }
}

run "policy_settings_without_optional_nested_blocks" {
  command = plan

  variables {
    target_service_account_email = "castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
    castai_service_account_email = "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
    autoscaler_settings = {
      enabled = true
    }
  }

  assert {
    condition     = length(castai_autoscaler_policies.castai_autoscaler_policies[0].unschedulable_pods) == 0
    error_message = "Unset unschedulable_pods should not emit a default block"
  }

  assert {
    condition     = length(castai_autoscaler_policies.castai_autoscaler_policies[0].cluster_limits) == 0
    error_message = "Unset cluster_limits should not emit a default block"
  }

  assert {
    condition     = length(castai_autoscaler_policies.castai_autoscaler_policies[0].node_downscaler) == 0
    error_message = "Unset node_downscaler should not emit a default block"
  }

  assert {
    condition     = length(castai_evictor.castai_evictor) == 0
    error_message = "Evictor should remain independent and unset"
  }
}
