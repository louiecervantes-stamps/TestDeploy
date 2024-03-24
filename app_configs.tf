variable "app_config" {
  description = "App related config"
  default = {
    "els" = {
      iam_instance_profile = "arn:aws:iam::609346200557:instance-profile/els_ec2_profile"
      instance_type        = "m6i.large"
      security_groups      = ["sg-02baddcf7487a9b7e", "sg-0d1c51780483ced6d"]
      target_groups        = ["arn:aws:elasticloadbalancing:us-west-1:609346200557:targetgroup/louie-els443/54f58521c69f762c", "arn:aws:elasticloadbalancing:us-west-1:609346200557:targetgroup/louie-els80/40eab07f00f0c0fb"]
      elb_present          = "Yes"
      elb                  = "louie-els-elb-public"
    }
  }
}

variable "common_config" {
  description = "Global app related config"
  default = {
    "subnet_id" = "subnet-0fa44e91bc5e28589"
    "key_name"  = "Stamps-AWS-KP"
    "owners"    = ["254816902897"]
  }
}

// set in workspace
variable "env" {
  type    = string
  default = "louie"
}

variable "vpc_id" {
  type    = string
  default = "vpc-078845fe6a8df1991"
}