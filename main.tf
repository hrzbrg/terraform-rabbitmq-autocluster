########## Terraform RabbitMQ Autocluster ##########

resource "aws_autoscaling_group" "rabbitmq-asg" {
  vpc_zone_identifier = [
    "${split(",", var.subnets["demo"])}",
  ]

  name                 = "rabbitmq-asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.rabbitmq-lc.name}"

  load_balancers = [
    "${aws_elb.rabbitmq-elb.name}",
  ]

  termination_policies = [
    "OldestLaunchConfiguration",
  ]

  min_elb_capacity = 3

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "rabbitmq-asg"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "environment"
    value               = "demo"
    propagate_at_launch = "true"
  }
}

# Launch Configuration for the cluster instances
resource "aws_launch_configuration" "rabbitmq-lc" {
  name_prefix          = "rabbitmq-lc-"
  image_id             = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${var.iam_role}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }

  # Security group
  security_groups = [
    "${aws_security_group.rabbitmq-sg.id}",
  ]

  user_data = "${file("userdata.sh")}"
  key_name  = "${var.key_name}"
}

# ELB in front of the cluster
resource "aws_elb" "rabbitmq-elb" {
  name = "demo-rabbitmq-elb"

  subnets = [
    "${split(",", var.subnets["demo"])}",
  ]

  security_groups = [
    "${aws_security_group.rabbitmq-elb-sg.id}",
  ]

  idle_timeout = 3600

  listener {
    instance_port      = 1883
    instance_protocol  = "tcp"
    lb_port            = 8883
    lb_protocol        = "ssl"
    ssl_certificate_id = "${var.ssl_cert["demo"]}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:1883"
    interval            = 30
  }
}

# Security Group for the cluster instances
resource "aws_security_group" "rabbitmq-sg" {
  description = "used for rabbitmq cluster instances"
  vpc_id      = "${var.vpc_id["demo"]}"

  tags {
    Name = "rabbitmq-sg"
  }

  # SSH access to instances
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/24",
    ]
  }

  # Management Port
  ingress {
    from_port = 15672
    to_port   = 15672
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/24",
    ]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    security_groups = [
      "${aws_security_group.rabbitmq-elb-sg.id}",
    ]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

# Security Group for the ELB
resource "aws_security_group" "rabbitmq-elb-sg" {
  description = "used for rabbitmq-elb"
  vpc_id      = "${var.vpc_id["demo"]}"

  tags {
    Name = "rabbitmq-elb-sg"
  }

  # MQTT SSL access
  ingress {
    from_port = 8883
    to_port   = 8883
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
