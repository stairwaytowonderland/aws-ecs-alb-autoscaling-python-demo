<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	api_id = <no default>
	application_name = <no default>
	environment = <no default>
	stage_name = <no default>

	# Optional variables
	key_description = null
	key_name_suffix = null
	plan_description = null
	plan_name_suffix = null
	quota_limit = 10
	quota_period = "MONTH"
	regenerate_key = false
	tags = {
  "ManagedBy": "Terraform"
}
	throttle_burst_limit = 5
	throttle_rate_limit = 10
	usage_plan_id = null
}
```

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_api_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_api_key) | resource |
| [aws_api_gateway_usage_plan.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_usage_plan_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan_key) | resource |
| [random_id.key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_id"></a> [api\_id](#input\_api\_id) | ID of the API Gateway REST API to associate with the usage plan | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Application name used in resource naming | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, nonprod, prod) | `string` | n/a | yes |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | Human-readable description of the API key | `string` | `null` | no |
| <a name="input_key_name_suffix"></a> [key\_name\_suffix](#input\_key\_name\_suffix) | Optional suffix appended before the resource-type token in the API key name (e.g. 'convert' → '{env}-{app}-convert-api-key'). If null, name is '{env}-{app}-api-key'. | `string` | `null` | no |
| <a name="input_plan_description"></a> [plan\_description](#input\_plan\_description) | Human-readable description of the usage plan (ignored when usage\_plan\_id is set) | `string` | `null` | no |
| <a name="input_plan_name_suffix"></a> [plan\_name\_suffix](#input\_plan\_name\_suffix) | Optional suffix appended before the resource-type token in the usage plan name (e.g. 'convert' → '{env}-{app}-convert-usage-plan'). If null, name is '{env}-{app}-usage-plan'. | `string` | `null` | no |
| <a name="input_quota_limit"></a> [quota\_limit](#input\_quota\_limit) | Maximum number of requests allowed in the quota period (ignored when usage\_plan\_id is set) | `number` | `10` | no |
| <a name="input_quota_period"></a> [quota\_period](#input\_quota\_period) | Period for the quota limit: DAY, WEEK, or MONTH (ignored when usage\_plan\_id is set) | `string` | `"MONTH"` | no |
| <a name="input_regenerate_key"></a> [regenerate\_key](#input\_regenerate\_key) | Whether to regenerate the API key | `bool` | `false` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the API Gateway stage to associate with the usage plan | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources | `map(string)` | <pre>{<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_throttle_burst_limit"></a> [throttle\_burst\_limit](#input\_throttle\_burst\_limit) | Maximum request burst size (token-bucket capacity) (ignored when usage\_plan\_id is set) | `number` | `5` | no |
| <a name="input_throttle_rate_limit"></a> [throttle\_rate\_limit](#input\_throttle\_rate\_limit) | Steady-state request rate limit in requests per second (ignored when usage\_plan\_id is set) | `number` | `10` | no |
| <a name="input_usage_plan_id"></a> [usage\_plan\_id](#input\_usage\_plan\_id) | ID of an existing usage plan to associate the key with. When set, no new usage plan is created. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key_id"></a> [api\_key\_id](#output\_api\_key\_id) | ID of the API key (retrieve value with: aws apigateway get-api-key --api-key <id> --include-value) |
| <a name="output_api_key_name"></a> [api\_key\_name](#output\_api\_key\_name) | Name of the API key |
| <a name="output_usage_plan_id"></a> [usage\_plan\_id](#output\_usage\_plan\_id) | ID of the usage plan (existing or newly created) |
| <a name="output_usage_plan_name"></a> [usage\_plan\_name](#output\_usage\_plan\_name) | Name of the newly created usage plan (null when usage\_plan\_id is provided) |
<!-- END_TF_DOCS -->
