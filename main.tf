resource "aws_security_group" "els_sg" {
  name        = "${var.env} ELS SG"
  description = "ELS Specific rules"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.env} ELS SG"
  }

  ingress {
    description = "Allow 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "els_sg" {
  value = aws_security_group.els_sg.id
}

resource "aws_security_group" "base_sg" {
  name        = "${var.env} Base App SG"
  description = "Common rules"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.env} Base App SG"
  }

  ingress {
    description = "Allow 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "base_sg" {
  value = aws_security_group.base_sg.id
}

resource "aws_security_group" "els_elb_sg" {
  name        = "${var.env} ELS ELB SG"
  description = "Load Balancer SG"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.env} ELS ELB SG"
  }

  ingress {
    description = "Allow 80 from Home IP only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["47.144.141.94/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "els_ec2_profile" {
  name = "els_ec2_profile"
  role = aws_iam_role.els_ec2_profile.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "els_ec2_profile" {
  name               = "els_ec2_profile"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}



resource "aws_lb_target_group" "els443" {
  name     = "louie-els443"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
}

output "els443" {
  value = aws_lb_target_group.els443.arn
}

resource "aws_lb_target_group" "els80" {
  name     = "louie-els80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

output "els80" {
  value = aws_lb_target_group.els80.arn
}

resource "aws_elb" "louie-els-elb-public" {
  name            = "louie-els-elb-public"
  subnets         = ["subnet-01b0f349bb4ad3495", "subnet-00d1eaf832488ace4"]
  security_groups = [aws_security_group.els_elb_sg.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    Name = "louie-els-elb-public"
  }
}



resource "aws_lb" "louie-els-alb-private" {
  name               = "louie-els-alb-private"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.els_elb_sg.id]
  subnets            = ["subnet-0fa44e91bc5e28589", "subnet-075c7c33f52cc06c8"]
}

resource "aws_lb_listener" "louie-els-alb-private" {
  load_balancer_arn = aws_lb.louie-els-alb-private.arn
  port              = 443
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.els80.arn
  }
}

#Create EC2 Keypair
resource "aws_key_pair" "stamps_aws_kp" {
  key_name   = "Stamps-AWS-KP"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrfQlLtvc46I9r2Mg4WaoU4Ry7f6nYwTBvogzpOnRyHhRV2c2H8zQTKCG6sQuoyNjdf+Rh1JgvEWIi4Tc7yPQh1bRJenm6QfsNbDVUI5/hyWkWSpNu30ijGRk8ViKKiIHuV/1ix/lrEyv0UmHr1QUYV6Or4yvslIDluWl4RGfdxf2jB0n6XIrny0igN2iSmCFBKsRjnnE2xQJub2U09BNbwocRrelKo2bgfeF/sEBd8QYpT0utXWgwbaMcNN17WCMWohG34+yVg5gN/m8+EGVYNjN6Ce21RGLl5Vam7/M2GUe4LGhH8l4/pQY8VnJavaV5+2w/NVP4hds6wgDkQWTX"
}