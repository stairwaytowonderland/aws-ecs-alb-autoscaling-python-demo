<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75.1 |

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	application_name = <no default>
	aws_region = <no default>
	oidc_subjects = <no default>

	# Optional variables
	additional_tags = {}
	create_cli_role = false
	environment = "dev"
	oidc_policy_map = {
  "ReadOnlyAccess": "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
	required_tags = {}
	role_name_prefix = "ci-provision"
}
```

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_bootstrap_role"></a> [iam\_bootstrap\_role](#module\_iam\_bootstrap\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | ~> v5.60 |
| <a name="module_iam_github_oidc_provider"></a> [iam\_github\_oidc\_provider](#module\_iam\_github\_oidc\_provider) | terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider | ~> v5.60 |
| <a name="module_iam_github_oidc_role"></a> [iam\_github\_oidc\_role](#module\_iam\_github\_oidc\_role) | terraform-aws-modules/iam/aws//modules/iam-github-oidc-role | ~> v5.60 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to all resources | `map(any)` | `{}` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy resources in | `string` | n/a | yes |
| <a name="input_create_cli_role"></a> [create\_cli\_role](#input\_create\_cli\_role) | Whether to create a cli role | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, nonprod, prod) | `string` | `"dev"` | no |
| <a name="input_oidc_policy_map"></a> [oidc\_policy\_map](#input\_oidc\_policy\_map) | Map of policy arns for oidc role | `map(string)` | <pre>{<br/>  "ReadOnlyAccess": "arn:aws:iam::aws:policy/ReadOnlyAccess"<br/>}</pre> | no |
| <a name="input_oidc_subjects"></a> [oidc\_subjects](#input\_oidc\_subjects) | List of subjects for the OIDC roles, typically GitHub or GitLab repository references | `list(string)` | n/a | yes |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | Tags that must be applied to all resources | <pre>object({<br/>    # These tags are here for convenience, and should be merged with the local calculated tags<br/>    ManagedBy   = optional(string, "Terraform")<br/>    Owner       = optional(string, null)<br/>    App         = optional(string, null)<br/>    Environment = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_role_name_prefix"></a> [role\_name\_prefix](#input\_role\_name\_prefix) | Prefix for IAM role names | `string` | `"ci-provision"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_role_arn"></a> [bootstrap\_role\_arn](#output\_bootstrap\_role\_arn) | n/a |
| <a name="output_bootstrap_role_name"></a> [bootstrap\_role\_name](#output\_bootstrap\_role\_name) | n/a |
| <a name="output_oidc_role_arn"></a> [oidc\_role\_arn](#output\_oidc\_role\_arn) | n/a |
| <a name="output_oidc_role_name"></a> [oidc\_role\_name](#output\_oidc\_role\_name) | n/a |
<!-- END_TF_DOCS -->
