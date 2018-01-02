resource "aws_elb" "my-elb" {
  name            = "my-elb"
  subnets         = ["${element(var.subnet-id, 0)}",
                     "${element(var.subnet-id, 1)}"]
  security_groups = ["${aws_security_group.elb-securitygroup.id}"]
#  access_logs {
#    bucket = "cdp-access-log-elb"
#    bucket_prefix = "my-app"
#    interval = 5
#  }
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 8140
    instance_protocol = "TCP"
    lb_port           = 8140
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "my-elb"
  }
}

resource "aws_security_group" "elb-securitygroup" {
  vpc_id      = "${var.vpc_id}"
  name        = "SG-for-elb"
  description = "security group for load balancer"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "SG-for-elb"
  }
}
