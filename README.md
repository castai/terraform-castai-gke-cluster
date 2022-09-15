<a href="https://cast.ai">
    <img src="https://cast.ai/wp-content/themes/cast/img/cast-logo-dark-blue.svg" align="right" height="100" />
</a>

Terraform module for connecting an GKE cluster to CAST AI
==================


Website: https://www.cast.ai

Requirements
------------

- [Terraform](https://www.terraform.io/downloads.html) 0.13+

Using the module
------------

A module to connect an GKE cluster to CAST AI.

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

}
```

[Example usage](https://github.com/castai/terraform-provider-castai/blob/master/examples/gke_cluster/main.tf)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 0.25.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 2.49 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_castai"></a> [castai](#provider\_castai) | >= 0.25.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [castai_autoscaler.castai_autoscaler_policies](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/autoscaler) | resource |
| [castai_gke_cluster.castai_cluster](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/gke_cluster) | resource |
| [castai_node_configuration.this](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/node_configuration) | resource |
| [helm_release.castai_agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.castai_cluster_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.castai_evictor](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.castai_spot_handler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_url"></a> [api\_url](#input\_api\_url) | URL of alternative CAST AI API to be used during development or testing | `string` | `"https://api.cast.ai"` | no |
| <a name="input_autoscaler_policies_json"></a> [autoscaler\_policies\_json](#input\_autoscaler\_policies\_json) | Optional json object to override CAST AI cluster autoscaler policies | `string` | `""` | no |
| <a name="input_castai_components_labels"></a> [castai\_components\_labels](#input\_castai\_components\_labels) | Optional additional Kubernetes labels for CAST AI pods | `map` | `{}` | no |
| <a name="input_default_node_configuration"></a> [default\_node\_configuration](#input\_default\_node\_configuration) | ID of the default node configuration | `string` | n/a | yes |
| <a name="input_delete_nodes_on_disconnect"></a> [delete\_nodes\_on\_disconnect](#input\_delete\_nodes\_on\_disconnect) | Optionally delete Cast AI created nodes when the cluster is destroyed | `bool` | `false` | no |
| <a name="input_gke_cluster_location"></a> [gke\_cluster\_location](#input\_gke\_cluster\_location) | Location of the cluster to be connected to CAST AI. Can be region or zone for zonal clusters | `string` | n/a | yes |
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name) | Name of the cluster to be connected to CAST AI. | `string` | n/a | yes |
| <a name="input_gke_credentials"></a> [gke\_credentials](#input\_gke\_credentials) | Optional GCP Service account credentials.json | `string` | n/a | yes |
| <a name="input_node_configurations"></a> [node\_configurations](#input\_node\_configurations) | Map of GKE node configurations to create | <pre>map(object({<br>    disk_cpu_ratio = optional(number)<br>    subnets        = list(string)<br>    ssh_public_key = optional(string)<br>    image          = optional(string)<br>    tags           = optional(map(string))<br>  }))</pre> | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project id from GCP | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_castai_node_configurations"></a> [castai\_node\_configurations](#output\_castai\_node\_configurations) | Map of node configurations ids by name |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | CAST.AI cluster id, which can be used for accessing cluster data using API |
<!-- END_TF_DOCS -->
