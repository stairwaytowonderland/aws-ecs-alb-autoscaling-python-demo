aws_region  = "us-east-2"
environment = "dev"
# application_name      = "candidate-app"
dynamodb_table_name   = "Candidates"
health_check_path     = "/gtg"
health_check_timeout  = 5
handle_docker         = true
force_docker_rebuild  = false
docker_build_context  = "../../.."
dockerfile_path_rel   = "docker/Dockerfile"
create_local_pem_file = false
additional_tags = {
  Sandbox = true
  Owner   = "Andrew Haller"
}
# create_custom_ami     = true
