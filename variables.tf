# Specify the provider and access details
provider "aws" {
  region = "eu-west-1"
}

variable "iam_role" {
  description = "The IAM role that is used for the instance"
  default     = ""
}

variable "ssl_cert" {
  type = "map"

  default = {
    demo = ""
  }

  description = "SSL certificates for ELB"
}

variable "vpc_id" {
  type = "map"

  default = {
    demo = "vpc-1234abcd"
  }
}

# Amazon Linux
variable "aws_amis" {
  type = "map"

  default = {
    "eu-west-1" = "ami-70edb016"
  }
}

variable "subnets" {
  type = "map"

  default = {
    demo = "subnet-1234abcd,subnet-abcd1234,subnet-ab12cd34"
  }

  description = "List of subnets to launch instances in."
}

variable "key_name" {
  default     = "some_ssh_key"
  description = "Name of AWS key pair"
}

variable "instance_type" {
  default     = "t2.medium"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "3"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "9"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "3"
}
