<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75.1 |

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	application_name = <no default>
	aws_region = <no default>

	# Optional variables
	additional_tags = {}
	backend_filename = "backend.auto.tf"
	backend_vars_suffix = "auto.backend"
	backends = {}
	environment = "dev"
	manage_backend_file = false
	required_tags = {}
	s3_force_destroy = false
	s3_state_key_name = "terraform.tfstate"
}
```

## Resources

| Name | Type |
|------|------|
| [local_file.backend_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.backend_config_vars](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_region.self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | ../../modules/dynamodb | n/a |
| <a name="module_s3_state"></a> [s3\_state](#module\_s3\_state) | ../../modules/s3_state | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to all resources | `map(any)` | `{}` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy resources in | `string` | n/a | yes |
| <a name="input_backend_filename"></a> [backend\_filename](#input\_backend\_filename) | The filename for the backend configuration | `string` | `"backend.auto.tf"` | no |
| <a name="input_backend_vars_suffix"></a> [backend\_vars\_suffix](#input\_backend\_vars\_suffix) | The filename suffix for the backend configuration vars | `string` | `"auto.backend"` | no |
| <a name="input_backends"></a> [backends](#input\_backends) | Map of backend configurations for different environments | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, nonprod, prod) | `string` | `"dev"` | no |
| <a name="input_manage_backend_file"></a> [manage\_backend\_file](#input\_manage\_backend\_file) | Whether to manage the backend tf configuration file | `bool` | `false` | no |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | Tags that must be applied to all resources | <pre>object({<br/>    # These tags are here for convenience, and should be merged with the local calculated tags<br/>    ManagedBy   = optional(string, "Terraform")<br/>    Owner       = optional(string, null)<br/>    App         = optional(string, null)<br/>    Environment = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_s3_force_destroy"></a> [s3\_force\_destroy](#input\_s3\_force\_destroy) | Whether to force destroy the S3 bucket | `bool` | `false` | no |
| <a name="input_s3_state_key_name"></a> [s3\_state\_key\_name](#input\_s3\_state\_key\_name) | The Terraform state file name | `string` | `"terraform.tfstate"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_configs_vars"></a> [backend\_configs\_vars](#output\_backend\_configs\_vars) | n/a |
<!-- END_TF_DOCS -->
