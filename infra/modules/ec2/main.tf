locals {
  region_name = data.aws_region.current.region

  ami      = var.ami_id != null ? one(data.aws_ami.this[*]) : one(data.aws_ami.base[*])
  base_ami = var.base_ami ? (var.create_custom_ami ? one(aws_instance.base_ami[*]) : null) : null
  ami_id   = var.base_ami ? (var.create_custom_ami ? one(aws_ami_from_instance.app[*]).id : local.ami.id) : local.ami.id
  ami_name = var.base_ami ? (var.create_custom_ami ? one(aws_ami_from_instance.app[*]).name : local.ami.name) : local.ami.name

  iam_instance_profile_name = var.base_ami ? one(aws_iam_instance_profile.app[*]).name : var.iam_instance_profile_name

  key_pair_name = format("%s-ec2-connect", var.environment)
  asg_name      = format("%s-app-asg", var.environment)

  launch_template_name = format("%s-app-launch-template", var.environment)

  asg_extra_tags = [
    {
      key                 = "Name"
      value               = local.asg_name
      propagate_at_launch = true
    },
    # {
    #   key                 = "Timestamp"
    #   value               = "Bam"
    #   propagate_at_launch = timestamp()
    # },
  ]

  docker_image_hostname = var.base_ami ? null : split("/", var.docker_image_url)[0]


  launch_template_setup_command = var.docker_install_command != null ? (<<-EOF
    # Update system
    yum update -y
    yum install -y unzip

    # Install Docker
    ${var.docker_install_command}
    systemctl enable docker
    systemctl start docker

    # Add ec2-user to docker group
    usermod -a -G docker ec2-user

    # Install AWS CLI v2
    # yum remove -y awscli
    # curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    # unzip awscliv2.zip
    # ./aws/install
    # rm -rf awscliv2.zip aws/
    [ -r /usr/local/bin/aws ] || ln -s /bin/aws /usr/local/bin/aws
    /usr/local/bin/aws --version
  EOF
  ) : null

  docker_run_command = var.docker_image_url != null ? (<<-EOF
    # Set region and login to ECR
    aws ecr get-login-password --region ${local.region_name} | docker login --username ${var.ecr_config_user_name} --password-stdin ${local.docker_image_hostname}

    docker run -d --name ${var.application_name} \
      -p 8000:8000 \
      -e TC_DYNAMO_TABLE=${var.dynamodb_table_name} \
      -e AWS_DEFAULT_REGION=${local.region_name} \
      --restart always \
      ${var.docker_image_url}
  EOF
  ) : null
}

resource "aws_iam_instance_profile" "app" {
  count = var.base_ami ? 1 : 0

  name = format("%v-app-instance-profile", var.environment)
  role = var.ec2_role_name
}

# Base instance for AMI creation
resource "aws_instance" "base_ami" {
  count = var.base_ami ? (var.create_custom_ami ? 1 : 0) : 0

  ami                    = local.ami.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = local.iam_instance_profile_name

  associate_public_ip_address = true

  user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    set -e

    ${local.launch_template_setup_command}
    EOF
  )

  tags = {
    Name    = format("%v-ami-builder-instance", var.environment)
    Purpose = "AMI Creation"
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

# Create custom AMI from the base instance
resource "aws_ami_from_instance" "app" {
  count = var.base_ami ? (var.create_custom_ami ? 1 : 0) : 0

  name                    = var.force_new_ami ? format("%v-%v-ami-%v", var.environment, var.application_name, formatdate("YYYY-MM-DD-hhmm", timestamp())) : format("%v-%v-ami", var.environment, var.application_name)
  source_instance_id      = local.base_ami.id
  snapshot_without_reboot = true

  tags = {
    Name        = format("%v-%v-ami", var.environment, var.application_name)
    CreatedFrom = local.base_ami.id
  }

  lifecycle {
    ignore_changes = [
      name,
      source_instance_id,
      tags["CreatedFrom"]
    ]

    # create_before_destroy = true
  }

  depends_on = [aws_instance.base_ami]
}

# Use null resource to manage base instance lifecycle, and terminate after AMI creation
resource "null_resource" "cleanup_base_instance" {
  count = var.base_ami ? (var.create_custom_ami ? 1 : 0) : 0

  # Terminate the base instance after AMI is created
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --region ${local.region_name} --instance-ids ${local.base_ami.id}"
  }

  # Trigger when AMI is created
  triggers = {
    ami_id = local.ami_id
  }

  depends_on = [aws_ami_from_instance.app]
}


resource "aws_launch_template" "app" {
  count = var.base_ami ? 0 : 1

  name                   = local.launch_template_name
  image_id               = local.ami_id
  instance_type          = var.instance_type
  update_default_version = true
  key_name               = var.base_ami ? null : aws_key_pair.ec2_connect[count.index].key_name

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  monitoring {
    enabled = false # Ensure free-tier
  }

  iam_instance_profile {
    name = local.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }

  # Conflicts with network_interfaces.security_groups
  # vpc_security_group_ids = [var.security_group_id]

  user_data = var.base_ami ? (var.create_custom_ami ? base64encode(<<-EOF
    #!/bin/bash
    set -e

    ${local.launch_template_setup_command}
    EOF
    ) : null) : (var.create_custom_ami ? base64encode(<<-EOF
    #!/bin/bash
    set -e

    ${local.docker_run_command}
    EOF
    ) : base64encode(<<-EOF
    #!/bin/bash
    set -e

    ${local.launch_template_setup_command}
    ${local.docker_run_command}
    EOF
  ))

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = format("%s-app-instance", var.environment)
      }
    )
  }
}

# ! Caution: Manually creating the service-linked role for EC2 Auto Scaling
# ! results in potentially long delays before the role can be deleted.
# Manually create the service-linked role for EC2 Auto Scaling
# resource "aws_iam_service_linked_role" "ec2_autoscaling" {
#   count = var.base_ami ? 0 : 1

#   aws_service_name = "autoscaling.amazonaws.com"
# }

resource "aws_autoscaling_group" "app" {
  count = var.base_ami ? 0 : 1

  name                = local.asg_name
  desired_capacity    = var.asg_desired_capacity
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns != null ? var.target_group_arns : []
  health_check_type   = var.target_group_arns != null ? "ELB" : "EC2"

  # Reference the ARN of the service-linked role
  # service_linked_role_arn = "arn:aws:iam::<aws-account-id>:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
  # NOTE:
  # A refresh will not start when version = "$Latest" is configured in the launch_template block.
  # To trigger the instance refresh when a launch template is changed,
  # configure version to use the latest_version attribute of the aws_launch_template resource.
  launch_template {
    id      = aws_launch_template.app[count.index].id
    version = aws_launch_template.app[count.index].latest_version # "$Latest" (see note above)
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }

    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#triggers-5
    # Set of additional property names that will trigger an Instance Refresh.
    # A refresh will always be triggered by a change in any of launch_configuration, launch_template, or mixed_instances_policy.
    triggers = ["tag"]
  }

  dynamic "tag" {
    for_each = local.asg_extra_tags

    content {
      key                 = tag.value.key
      propagate_at_launch = tag.value.propagate_at_launch
      value               = tag.value.value
    }
  }

  # depends_on = [ aws_iam_service_linked_role.ec2_autoscaling ]

  lifecycle {
    create_before_destroy = true
  }
}

# Generate a new private key
resource "tls_private_key" "ec2" {
  count = var.base_ami ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS EC2 key pair using the generated public key
resource "aws_key_pair" "ec2_connect" {
  count = var.base_ami ? 0 : 1

  key_name   = local.key_pair_name
  public_key = tls_private_key.ec2[count.index].public_key_openssh

  tags = {
    Name = local.key_pair_name
  }
}
