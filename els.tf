// Variables.tf
variable "elsbuilds" {
  type = list(any)
}

variable "elslive" {
  type = string
}

// Lookup the AMI IDs for the builds
data "aws_ami" "els" {
  for_each = toset(var.elsbuilds)
  owners   = var.common_config.owners

  filter {
    name   = "name"
    values = [each.key]
  }
}

// Loop and create launch template for all builds 
resource "aws_launch_template" "els" {
  for_each = toset(var.elsbuilds)
  name     = each.key

  iam_instance_profile {
    arn = var.app_config.els.iam_instance_profile
  }

  image_id      = data.aws_ami.els[each.key].image_id
  instance_type = var.app_config.els.instance_type
  //  key_name = var.common_config.key_name

  network_interfaces {
    subnet_id       = var.common_config.subnet_id
    security_groups = var.app_config.els.security_groups
  }

  user_data = base64encode(templatefile("userdata.tftpl", { buildnumber = each.key }))

}

// ASGs
resource "aws_autoscaling_group" "els" {
  for_each           = toset(var.elsbuilds)
  name               = "${var.env}_${each.key}"
  availability_zones = ["us-west-1b"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.els[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = each.key
    propagate_at_launch = true
  }

}

// Attachments for live build
resource "aws_autoscaling_attachment" "els_443" {
  for_each               = toset(var.app_config.els.target_groups)
  autoscaling_group_name = aws_autoscaling_group.els[var.elslive].id
  lb_target_group_arn    = each.key
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "els_80" {
  for_each               = toset(var.app_config.els.target_groups)
  autoscaling_group_name = aws_autoscaling_group.els[var.elslive].id
  lb_target_group_arn    = each.key
  lifecycle {
    create_before_destroy = true
  }
}

// sample classic
resource "aws_autoscaling_attachment" "els_elb" {
  count                  = var.app_config.els.elb_present == "Yes" ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.els[var.elslive].id
  elb                    = var.app_config.els.elb
  lifecycle {
    create_before_destroy = true
  }
}


