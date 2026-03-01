aws_region  = "us-east-2"
environment = "dev"
additional_tags = {
  Sandbox = true
  Owner   = "Andrew Haller"
}
application_name    = "candidate-app"
dynamodb_table_name = "Candidates"
ami_name_pattern    = "al2023-ami-*-kernel-6.1-x86_64"
top_cidr            = "10.0.0.0/16"
# create_custom_ami   = true
