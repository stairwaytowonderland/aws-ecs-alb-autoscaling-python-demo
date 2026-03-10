aws_region       = "us-east-2"
environment      = "dev"
# application_name = "candidate-app"
additional_tags = {
  Sandbox = true
  Owner   = "Andrew Haller"
}
backends = {
  bootstrap   = "../bootstrap"
  platform    = "../platform"
  application = "../app"
}
backend_filename    = "backend.tf"
backend_vars_suffix = "auto.backend"
manage_backend_file = false
s3_force_destroy    = true
