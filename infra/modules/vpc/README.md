<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	azs = <no default>
	environment = <no default>

	# Optional variables
	ipam_pool_id = null
	vpc_cidr = "10.0.0.0/8"
}
```

## Resources

| Name | Type |
|------|------|
| [aws_security_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | aws-ia/vpc/aws | ~> 4.5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input\_azs) | Availability zones to use | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, nonprod, prod) | `string` | n/a | yes |
| <a name="input_ipam_pool_id"></a> [ipam\_pool\_id](#input\_ipam\_pool\_id) | The ID of the IPAM pool to use for VPC CIDR allocation | `string` | `null` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/8"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_subnet_ids_by_az"></a> [public\_subnet\_ids\_by\_az](#output\_public\_subnet\_ids\_by\_az) | List of public subnet IDs |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the application security group |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->
