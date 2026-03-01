<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.75.1 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 3.0 |
| <a name="requirement_git"></a> [git](#requirement\_git) | 2025.7.18 |

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	ami_name_pattern = <no default>
	application_name = <no default>
	aws_region = <no default>
	dynamodb_table_name = <no default>
	top_cidr = <no default>

	# Optional variables
	additional_tags = {}
	assume_ecr_repository = true
	create_custom_ami = null
	create_ipam = false
	docker_install_command = "yum install -y docker"
	environment = "dev"
	force_new_ami = null
	required_tags = {}
}
```

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_for_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [aws_iam_policy.ecs_for_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_region.self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc_ipam_pool.self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_ipam_pool) | data source |
| [git_commit.current_commit](https://registry.terraform.io/providers/metio/git/2025.7.18/docs/data-sources/commit) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_ami"></a> [ec2\_ami](#module\_ec2\_ami) | ../../modules/ec2 | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../modules/ecr | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to all resources | `map(any)` | `{}` | no |
| <a name="input_ami_name_pattern"></a> [ami\_name\_pattern](#input\_ami\_name\_pattern) | n/a | `any` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application | `string` | n/a | yes |
| <a name="input_assume_ecr_repository"></a> [assume\_ecr\_repository](#input\_assume\_ecr\_repository) | Flag to use an ECR repository for Docker images | `bool` | `true` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy resources in | `string` | n/a | yes |
| <a name="input_create_custom_ami"></a> [create\_custom\_ami](#input\_create\_custom\_ami) | n/a | `any` | `null` | no |
| <a name="input_create_ipam"></a> [create\_ipam](#input\_create\_ipam) | Flag to create the IPAM module | `bool` | `false` | no |
| <a name="input_docker_install_command"></a> [docker\_install\_command](#input\_docker\_install\_command) | The Docker install command | `string` | `"yum install -y docker"` | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | n/a | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, nonprod, prod) | `string` | `"dev"` | no |
| <a name="input_force_new_ami"></a> [force\_new\_ami](#input\_force\_new\_ami) | n/a | `any` | `null` | no |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | Tags that must be applied to all resources | <pre>object({<br/>    # These tags are here for convenience, and should be merged with the local calculated tags<br/>    ManagedBy   = optional(string, "Terraform")<br/>    Owner       = optional(string, null)<br/>    App         = optional(string, null)<br/>    Environment = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_top_cidr"></a> [top\_cidr](#input\_top\_cidr) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | ID of the AMI |
| <a name="output_ec2_role_name"></a> [ec2\_role\_name](#output\_ec2\_role\_name) | Name of the EC2 role |
| <a name="output_ecr_username"></a> [ecr\_username](#output\_ecr\_username) | Username for ECR authentication |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | Name of the IAM instance profile |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Map of public subnet IDs |
| <a name="output_public_subnet_ids_json"></a> [public\_subnet\_ids\_json](#output\_public\_subnet\_ids\_json) | Map of public subnet IDs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
| <a name="output_vpc_security_group_id"></a> [vpc\_security\_group\_id](#output\_vpc\_security\_group\_id) | The ID of the VPC security group |
<!-- END_TF_DOCS -->
