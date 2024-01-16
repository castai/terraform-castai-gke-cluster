<a href="https://cast.ai">
    <img src="https://cast.ai/wp-content/themes/cast/img/cast-logo-dark-blue.svg" align="right" height="100" />
</a>

Terraform module for connecting a GKE cluster to CAST AI
==================


Website: https://www.cast.ai

Requirements
------------

- [Terraform](https://www.terraform.io/downloads.html) 0.13+

Using the module
------------

A module to connect a GKE cluster to CAST AI.

Requires `castai/castai` and `hashicorp/google` providers to be configured.

For Phase 2 onboarding credentials from `terraform-gke-iam` are required

```hcl
module "castai_gke_cluster" {
  source = "castai/gke-cluster/castai"
  
  project_id = var.project_id
  gke_cluster_name = var.cluster_name
  gke_cluster_location = module.gke.location # cluster region or zone  

  gke_credentials = module.castai_gke_iam.private_key
  delete_nodes_on_disconnect = var.delete_nodes_on_disconnect
  autoscaler_policies_json      = var.autoscaler_policies_json

  default_node_configuration = module.castai_gke_cluster.node_configurations["default"]

  node_configurations = {
    default = {
      disk_cpu_ratio = 25
      subnets        = [module.vpc.subnets_ids[0]]
      tags           = {
        "node-config" : "default"
      }
      gke = {
        max_pods_per_node = 110
        network_tags      = ["dev"]
        disk_type         = "pd-balanced"
      }
    }
  }
  node_templates = {
    spot_tmpl = {
      configuration_id = module.castai_gke_cluster.node_configurations["default"]

      should_taint = true

      custom_labels = {
        custom-label-key-1 = "custom-label-value-1"
        custom-label-key-2 = "custom-label-value-2"
      }

      custom_taints = [
        {
          key = "custom-taint-key-1"
          value = "custom-taint-value-1"
        },
        {
          key = "custom-taint-key-2"
          value = "custom-taint-value-2"
        }
      ]

      constraints = {
        fallback_restore_rate_seconds = 1800
        spot = true
        use_spot_fallbacks = true
        min_cpu = 4
        max_cpu = 100
        instance_families = {
          exclude = ["e2"]
        }
        compute_optimized = false
        storage_optimized = false
        is_gpu_only       = false
        architectures     = ["amd64"]
      }

      custom_instances_enabled = true
    }
  }
}
```

Migrating from 3.x.x to 4.x.x
---------------------------

Version 4.x.x changes:
* Removed `custom_label` attribute in `castai_node_template` resource. Use `custom_labels` instead.

Old configuration:
```terraform
module "castai-gke-cluster" {
  node_templates = {
    spot_tmpl = {
      custom_label = {
        key = "custom-label-key-1"
        value = "custom-label-value-1"
      }
    }
  }
}
```

New configuration:
```terraform
module "castai-gke-cluster" {
  node_templates = {
    spot_tmpl = {
      custom_labels = {
        custom-label-key-1 = "custom-label-value-1"
      }
    }
  }
}
```


# Examples

Usage examples are located in [terraform provider repo](https://github.com/castai/terraform-provider-castai/tree/master/examples/gke)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 5.3.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 2.49 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_castai"></a> [castai](#provider\_castai) | >= 5.3.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [castai_autoscaler.castai_autoscaler_policies](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/autoscaler) | resource |
| [castai_gke_cluster.castai_cluster](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/gke_cluster) | resource |
| [castai_node_configuration.this](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/node_configuration) | resource |
| [castai_node_configuration_default.this](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/node_configuration_default) | resource |
| [castai_node_template.this](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/node_template) | resource |
| [helm_release.castai_agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.castai_cluster_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.castai_evictor](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.castai_kvisor](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.castai_spot_handler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.wait_for_cluster](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name                                                                                                                   | Description                                                                                                                           | Type           | Default                 | Required |
|------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|----------------|-------------------------|:--------:|
| <a name="input_agent_values"></a> [agent\_values](#input\_agent\_values)                                               | List of YAML formatted string values for agent helm chart                                                                             | `list(string)` | `[]`                    |    no    |
| <a name="input_api_url"></a> [api\_url](#input\_api\_url)                                                              | URL of alternative CAST AI API to be used during development or testing                                                               | `string`       | `"https://api.cast.ai"` |    no    |
| <a name="input_autoscaler_policies_json"></a> [autoscaler\_policies\_json](#input\_autoscaler\_policies\_json)         | Optional json object to override CAST AI cluster autoscaler policies                                                                  | `string`       | `""`                    |    no    |
| <a name="input_castai_api_token"></a> [castai\_api\_token](#input\_castai\_api\_token)                                 | Optional CAST AI API token created in console.cast.ai API Access keys section. Used only when `wait_for_cluster_ready` is set to true | `string`       | `""`                    |    no    |
| <a name="input_castai_components_labels"></a> [castai\_components\_labels](#input\_castai\_components\_labels)         | Optional additional Kubernetes labels for CAST AI pods                                                                                | `map(any)`     | `{}`                    |    no    |
| <a name="input_cluster_controller_values"></a> [cluster\_controller\_values](#input\_cluster\_controller\_values)      | List of YAML formatted string values for cluster-controller helm chart                                                                | `list(string)` | `[]`                    |    no    |
| <a name="input_default_node_configuration"></a> [default\_node\_configuration](#input\_default\_node\_configuration)   | ID of the default node configuration                                                                                                  | `string`       | n/a                     |   yes    |
| <a name="input_delete_nodes_on_disconnect"></a> [delete\_nodes\_on\_disconnect](#input\_delete\_nodes\_on\_disconnect) | Optionally delete Cast AI created nodes when the cluster is destroyed                                                                 | `bool`         | `false`                 |    no    |
| <a name="input_evictor_values"></a> [evictor\_values](#input\_evictor\_values)                                         | List of YAML formatted string values for evictor helm chart                                                                           | `list(string)` | `[]`                    |    no    |
| <a name="input_gke_cluster_location"></a> [gke\_cluster\_location](#input\_gke\_cluster\_location)                     | Location of the cluster to be connected to CAST AI. Can be region or zone for zonal clusters                                          | `string`       | n/a                     |   yes    |
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name)                                 | Name of the cluster to be connected to CAST AI.                                                                                       | `string`       | n/a                     |   yes    |
| <a name="input_gke_credentials"></a> [gke\_credentials](#input\_gke\_credentials)                                      | Optional GCP Service account credentials.json                                                                                         | `string`       | n/a                     |   yes    |
| <a name="input_grpc_url"></a> [grpc\_url](#input\_grpc\_url)                                                           | URL of alternative CAST AI gRPC to be used during development or testing                                                              | `string`       | `"grpc.cast.ai:443"`    |    no    |
| <a name="input_install_security_agent"></a> [install\_security\_agent](#input\_install\_security\_agent)               | Optional flag for installation of security agent (https://docs.cast.ai/product-overview/console/security-insights/)                   | `bool`         | `false`                 |    no    |
| <a name="input_kvisor_values"></a> [kvisor\_values](#input\_kvisor\_values)                                            | List of YAML formatted string values for kvisor helm chart                                                                            | `list(string)` | `[]`                    |    no    |
| <a name="input_node_configurations"></a> [node\_configurations](#input\_node\_configurations)                          | Map of GKE node configurations to create                                                                                              | `any`          | `{}`                    |    no    |
| <a name="input_node_templates"></a> [node\_templates](#input\_node\_templates)                                         | Map of node templates to create                                                                                                       | `any`          | `{}`                    |    no    |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id)                                                     | The project id from GCP                                                                                                               | `string`       | n/a                     |   yes    |
| <a name="input_spot_handler_values"></a> [spot\_handler\_values](#input\_spot\_handler\_values)                        | List of YAML formatted string values for spot-handler helm chart                                                                      | `list(string)` | `[]`                    |    no    |
| <a name="input_wait_for_cluster_ready"></a> [wait\_for\_cluster\_ready](#input\_wait\_for\_cluster\_ready)             | Wait for cluster to be ready before finishing the module execution, this option requires `castai_api_token` to be set                 | `bool`         | `false`                 |    no    |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_castai_node_configurations"></a> [castai\_node\_configurations](#output\_castai\_node\_configurations) | Map of node configurations ids by name |
| <a name="output_castai_node_templates"></a> [castai\_node\_templates](#output\_castai\_node\_templates) | Map of node template by name |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | CAST.AI cluster id, which can be used for accessing cluster data using API |
<!-- END_TF_DOCS -->
