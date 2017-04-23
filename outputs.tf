output "security_group" {
  value = "${aws_security_group.rabbitmq-sg.id}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.rabbitmq-lc.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.rabbitmq-asg.id}"
}

output "elb_name" {
  value = "${aws_elb.rabbitmq-elb.dns_name}"
}
