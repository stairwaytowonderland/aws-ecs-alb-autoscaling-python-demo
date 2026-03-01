aws_region = "us-east-2"
# oidc_subjects = ["repo:andrewhaller/tc-candidate-ahaller:ref:refs/heads/main", "repo:andrewhaller/tc-candidate-ahaller:ref:refs/tags/*"]
oidc_subjects = [
  # Personal repository
  "repo:stairwaytowonderland/aws-ecs-alb-autoscaling-python-demo:ref:refs/heads/main",
  "repo:stairwaytowonderland/aws-ecs-alb-autoscaling-python-demo:ref:refs/tags/*",
  # Additional public repositories...
]

oidc_policy_map = {
  AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
}
role_name_prefix = "ci-provision"
application_name = "candidate-app"
additional_tags = {
  Sandbox = true
  Owner   = "Andrew Haller"
}
create_cli_role = false
