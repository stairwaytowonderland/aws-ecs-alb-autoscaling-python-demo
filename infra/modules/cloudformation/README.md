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
	stack_name = <no default>

	# Optional variables
	cloudformation = ""
	enabled = true
	file_only = false
	filename = ""
	mode = "create"
	owner_name = ""
	role_name_prefix = "ci-provision"
	template_vars = {}
}
```

## Resources

| Name | Type |
|------|------|
| [local_file.cloudformation](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.delete](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.stack](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_cloudformation_stack.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudformation_stack) | data source |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy resources in | `string` | n/a | yes |
| <a name="input_cloudformation"></a> [cloudformation](#input\_cloudformation) | Additional CloudFormation as a string | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to enable the CloudFormation stack operation | `bool` | `true` | no |
| <a name="input_file_only"></a> [file\_only](#input\_file\_only) | If true, only create the CloudFormation template file without deploying the stack | `bool` | `false` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | The CloudFormation template filename | `string` | `""` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | Mode of operation: create, update, or delete the CloudFormation stack | `string` | `"create"` | no |
| <a name="input_owner_name"></a> [owner\_name](#input\_owner\_name) | Name of the owner of the resources | `string` | `""` | no |
| <a name="input_role_name_prefix"></a> [role\_name\_prefix](#input\_role\_name\_prefix) | Prefix for IAM role names | `string` | `"ci-provision"` | no |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | The name of the CloudFormation stack | `string` | n/a | yes |
| <a name="input_template_vars"></a> [template\_vars](#input\_template\_vars) | Map of variables to pass to the CloudFormation template | `any` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
