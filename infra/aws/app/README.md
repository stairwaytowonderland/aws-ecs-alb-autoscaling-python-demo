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
	application_name = <no default>
	aws_region = <no default>
	docker_build_context = <no default>
	dockerfile_path_rel = <no default>
	dynamodb_table_name = <no default>
	health_check_path = <no default>
	health_check_timeout = <no default>

	# Optional variables
	additional_tags = {}
	assume_ecr_repository = true
	create_custom_ami = false
	create_local_pem_file = false
	docker_install_command = "yum install -y docker"
	dynamodb_ttl_enabled = null
	environment = "dev"
	force_docker_rebuild = null
	handle_docker = null
	required_tags = {}
}
```

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy.dynamodb_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [local_file.private_key_pem_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [aws_instances.running](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [git_commit.current_commit](https://registry.terraform.io/providers/metio/git/2025.7.18/docs/data-sources/commit) | data source |
| [terraform_remote_state.platform](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/alb | n/a |
| <a name="module_docker"></a> [docker](#module\_docker) | ../../modules/docker | n/a |
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | ../../modules/dynamodb | n/a |
| <a name="module_ec2_autoscaling"></a> [ec2\_autoscaling](#module\_ec2\_autoscaling) | ../../modules/ec2 | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to all resources | `map(any)` | `{}` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application | `string` | n/a | yes |
| <a name="input_assume_ecr_repository"></a> [assume\_ecr\_repository](#input\_assume\_ecr\_repository) | Flag to use an ECR repository for Docker images | `bool` | `true` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy resources in | `string` | n/a | yes |
| <a name="input_create_custom_ami"></a> [create\_custom\_ami](#input\_create\_custom\_ami) | Flag to create a custom AMI for EC2 instances | `bool` | `false` | no |
| <a name="input_create_local_pem_file"></a> [create\_local\_pem\_file](#input\_create\_local\_pem\_file) | Flag to create a local PEM file for EC2 access | `bool` | `false` | no |
| <a name="input_docker_build_context"></a> [docker\_build\_context](#input\_docker\_build\_context) | n/a | `any` | n/a | yes |
| <a name="input_docker_install_command"></a> [docker\_install\_command](#input\_docker\_install\_command) | The Docker install command | `string` | `"yum install -y docker"` | no |
| <a name="input_dockerfile_path_rel"></a> [dockerfile\_path\_rel](#input\_dockerfile\_path\_rel) | n/a | `any` | n/a | yes |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | n/a | `any` | n/a | yes |
| <a name="input_dynamodb_ttl_enabled"></a> [dynamodb\_ttl\_enabled](#input\_dynamodb\_ttl\_enabled) | n/a | `any` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, nonprod, prod) | `string` | `"dev"` | no |
| <a name="input_force_docker_rebuild"></a> [force\_docker\_rebuild](#input\_force\_docker\_rebuild) | n/a | `any` | `null` | no |
| <a name="input_handle_docker"></a> [handle\_docker](#input\_handle\_docker) | n/a | `any` | `null` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | n/a | `any` | n/a | yes |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | n/a | `any` | n/a | yes |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | Tags that must be applied to all resources | <pre>object({<br/>    # These tags are here for convenience, and should be merged with the local calculated tags<br/>    ManagedBy   = optional(string, "Terraform")<br/>    Owner       = optional(string, null)<br/>    App         = optional(string, null)<br/>    Environment = optional(string, null)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the Application Load Balancer |
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | ID of the AMI used for EC2 instances |
| <a name="output_app_url"></a> [app\_url](#output\_app\_url) | URL to access the application via the load balancer |
| <a name="output_commit_hash"></a> [commit\_hash](#output\_commit\_hash) | Git commit hash used for the Docker image tag |
| <a name="output_ec2_private_key_pem"></a> [ec2\_private\_key\_pem](#output\_ec2\_private\_key\_pem) | PEM-encoded private key for EC2 instances |
| <a name="output_ec2_private_key_pem_path"></a> [ec2\_private\_key\_pem\_path](#output\_ec2\_private\_key\_pem\_path) | Path to the EC2 private key PEM file |
| <a name="output_ecr_image_tag"></a> [ecr\_image\_tag](#output\_ecr\_image\_tag) | Docker image tag used in ECR |
| <a name="output_ephemeral_instance_ids"></a> [ephemeral\_instance\_ids](#output\_ephemeral\_instance\_ids) | List of currently running instance IDs (ephemeral) in the specified VPC |
| <a name="output_src_files"></a> [src\_files](#output\_src\_files) | List of the source files used for building the Docker image |
| <a name="output_src_hash"></a> [src\_hash](#output\_src\_hash) | Combined hash of the source files used for building the Docker image |
| <a name="output_src_hashes"></a> [src\_hashes](#output\_src\_hashes) | List of separate hashes of the source files used for building the Docker image |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC used for EC2 instances |
<!-- END_TF_DOCS -->
