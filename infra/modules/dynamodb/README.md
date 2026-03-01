<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	environment = <no default>
	hash_key = <no default>
	table_name = <no default>

	# Optional variables
	tags = {
  "ManagedBy": "Terraform"
}
	ttl_enabled = false
}
```

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, nonprod, prod) | `string` | n/a | yes |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | The partition key for the DynamoDB table. | `string` | n/a | yes |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | The name of the DynamoDB table. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources | `map(string)` | <pre>{<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_ttl_enabled"></a> [ttl\_enabled](#input\_ttl\_enabled) | Enable Time to Live (TTL) for the DynamoDB table. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_table_arn"></a> [table\_arn](#output\_table\_arn) | ARN of the DynamoDB table |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | Name of the DynamoDB table |
| <a name="output_ttl"></a> [ttl](#output\_ttl) | The Time to Live (TTL) attribute for the DynamoDB table |
<!-- END_TF_DOCS -->
