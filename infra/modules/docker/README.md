<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | >= 3.0 |

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
	source = "<module-path>"

	# Required variables
	application_name = <no default>
	auth_config_address = <no default>
	auth_config_password = <no default>
	auth_config_username = <no default>
	docker_image_url = <no default>
	ecr_authorization_token_endpoint = <no default>

	# Optional variables
	docker_build_context = "."
	dockerfile_path = "Dockerfile"
	force_docker_rebuild = false
	handle_docker = false
	use_local_exec = false
}
```

## Resources

| Name | Type |
|------|------|
| [docker_image.app](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_registry_image.handler](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/registry_image) | resource |
| [null_resource.docker_build_push](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application | `string` | n/a | yes |
| <a name="input_auth_config_address"></a> [auth\_config\_address](#input\_auth\_config\_address) | Address for Docker registry authentication | `string` | n/a | yes |
| <a name="input_auth_config_password"></a> [auth\_config\_password](#input\_auth\_config\_password) | Password for Docker registry authentication | `string` | n/a | yes |
| <a name="input_auth_config_username"></a> [auth\_config\_username](#input\_auth\_config\_username) | Username for Docker registry authentication | `string` | n/a | yes |
| <a name="input_docker_build_context"></a> [docker\_build\_context](#input\_docker\_build\_context) | Path to the Docker build context | `string` | `"."` | no |
| <a name="input_docker_image_url"></a> [docker\_image\_url](#input\_docker\_image\_url) | URL of the Docker image | `string` | n/a | yes |
| <a name="input_dockerfile_path"></a> [dockerfile\_path](#input\_dockerfile\_path) | Path to the Dockerfile | `string` | `"Dockerfile"` | no |
| <a name="input_ecr_authorization_token_endpoint"></a> [ecr\_authorization\_token\_endpoint](#input\_ecr\_authorization\_token\_endpoint) | Endpoint for ECR authorization token | `string` | n/a | yes |
| <a name="input_force_docker_rebuild"></a> [force\_docker\_rebuild](#input\_force\_docker\_rebuild) | Force Docker image rebuild | `bool` | `false` | no |
| <a name="input_handle_docker"></a> [handle\_docker](#input\_handle\_docker) | Whether to provision any docker resources | `bool` | `false` | no |
| <a name="input_use_local_exec"></a> [use\_local\_exec](#input\_use\_local\_exec) | Use local-exec provisioner for Docker build and push | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_docker_image_url"></a> [docker\_image\_url](#output\_docker\_image\_url) | URL for the Docker image |
| <a name="output_docker_registry_address"></a> [docker\_registry\_address](#output\_docker\_registry\_address) | Address of the Docker registry |
| <a name="output_src_files"></a> [src\_files](#output\_src\_files) | List of the source files used for building the Docker image |
| <a name="output_src_hash"></a> [src\_hash](#output\_src\_hash) | Combined hash of the source files used for building the Docker image |
| <a name="output_src_hashes"></a> [src\_hashes](#output\_src\_hashes) | List of separate hashes of the source files used for building the Docker image |
<!-- END_TF_DOCS -->
