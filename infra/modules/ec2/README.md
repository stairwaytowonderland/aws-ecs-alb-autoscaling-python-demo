<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	application_name = <no default>
	ec2_role_name = <no default>
	environment = <no default>
	security_group_id = <no default>
	subnet_ids = <no default>

	# Optional variables
	ami_id = null
	ami_name_pattern = "al2023-ami-*-kernel-6.1-x86_64"
	asg_desired_capacity = 1
	asg_max_size = 2
	asg_min_size = 1
	base_ami = false
	create_custom_ami = false
	docker_image_url = null
	docker_install_command = "yum install -y docker"
	dynamodb_table_name = null
	ecr_config_user_name = "AWS"
	force_new_ami = false
	iam_instance_profile_name = null
	instance_type = "t2.micro"
	tags = {
  "ManagedBy": "Terraform"
}
	target_group_arns = null
}
```

## Resources

| Name | Type |
|------|------|
| [aws_ami_from_instance.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami_from_instance) | resource |
| [aws_autoscaling_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_instance.base_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.ec2_connect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [null_resource.cleanup_base_instance](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.ec2](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID to use for the EC2 instances | `string` | `null` | no |
| <a name="input_ami_name_pattern"></a> [ami\_name\_pattern](#input\_ami\_name\_pattern) | The AMI name pattern for the search filter | `string` | `"al2023-ami-*-kernel-6.1-x86_64"` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application | `string` | n/a | yes |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | Desired capacity of the Auto Scaling Group | `number` | `1` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | Maximum size of the Auto Scaling Group | `number` | `2` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | Minimum size of the Auto Scaling Group | `number` | `1` | no |
| <a name="input_base_ami"></a> [base\_ami](#input\_base\_ami) | Flag to determine if module is in base AMI creation/retrieval mode | `bool` | `false` | no |
| <a name="input_create_custom_ami"></a> [create\_custom\_ami](#input\_create\_custom\_ami) | Flag to create a custom AMI for the EC2 instances | `bool` | `false` | no |
| <a name="input_docker_image_url"></a> [docker\_image\_url](#input\_docker\_image\_url) | URL of the Docker image | `string` | `null` | no |
| <a name="input_docker_install_command"></a> [docker\_install\_command](#input\_docker\_install\_command) | The Docker install command | `string` | `"yum install -y docker"` | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | Name of the DynamoDB table | `string` | `null` | no |
| <a name="input_ec2_role_name"></a> [ec2\_role\_name](#input\_ec2\_role\_name) | Name of the IAM role for EC2 instances | `string` | n/a | yes |
| <a name="input_ecr_config_user_name"></a> [ecr\_config\_user\_name](#input\_ecr\_config\_user\_name) | Username for ECR authentication | `string` | `"AWS"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, nonprod, prod) | `string` | n/a | yes |
| <a name="input_force_new_ami"></a> [force\_new\_ami](#input\_force\_new\_ami) | Force creation of a new AMI with timestamp | `bool` | `false` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | Name of the created IAM instance profile for EC2 instances | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t2.micro"` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Security group ID for the EC2 instances | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the autoscaling group | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources | `map(string)` | <pre>{<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | List of target group ARNs for the Auto Scaling Group | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | ID of the AMI |
| <a name="output_ami_name"></a> [ami\_name](#output\_ami\_name) | Name of the AMI |
| <a name="output_asg_id"></a> [asg\_id](#output\_asg\_id) | ID of the autoscaling group |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the autoscaling group |
| <a name="output_ec2_private_key_pem"></a> [ec2\_private\_key\_pem](#output\_ec2\_private\_key\_pem) | n/a |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | Name of the IAM instance profile for EC2 instances |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | ID of the launch template |
<!-- END_TF_DOCS -->
