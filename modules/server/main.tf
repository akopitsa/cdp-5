// MAIN TF server


resource "aws_security_group" "allow-puppet" {
  vpc_id      = "${var.vpc_id}"
  name        = "allow-ssh-puppet"
  description = "security group that allows ssh and all egress traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${var.elb_sg_id}"]
  }

  ingress {
    from_port       = 8140
    to_port         = 8140
    protocol        = "tcp"
    security_groups = ["${var.elb_sg_id}"]
  }

  tags {
    Name = "allow-ssh-puppet-port"
  }
}

data "template_file" "puppet-server" {
  template = "${file("./modules/server/install_server.sh")}"

  vars {
    dns_name = "${var.dns_name}"
  }
}

resource "aws_launch_configuration" "cdp-launchconfig" {
  name_prefix     = "PuppetServer-launchconfig"
  image_id        = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type   = "t2.micro"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.allow-puppet.id}"]

  root_block_device {
    volume_size           = "12"
    delete_on_termination = true
  }

  user_data = "${data.template_file.puppet-server.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cdp-autoscaling" {
  name = "PuppetServer-autoscaling"

  vpc_zone_identifier = ["${element(var.subnet-id, 3)}",
                         "${element(var.subnet-id, 4)}"]

  launch_configuration      = "${aws_launch_configuration.cdp-launchconfig.name}"
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers            = ["${var.elb-name}"]
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "PuppetServer ec2 instance"
    propagate_at_launch = true
  }
}

// ===================================================================
data "template_file" "puppet-agent" {
  template = "${file("./modules/server/install_agent.sh")}"

  vars {
    dns_name = "${var.dns_name}"
  }
}

resource "aws_instance" "puppet-agent" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"

  #    availability_zone = "${var.AVAILABILITY_ZONE}"
  root_block_device {
    volume_size           = "8"
    delete_on_termination = true
  }

  vpc_security_group_ids = ["${aws_security_group.allow-puppet.id}"]
  key_name               = "${var.key_name}"
  #subnet_id              = "${module.vpc-mod.aws_private_subnet_id_1}"
  subnet_id              = "${element(var.subnet-id, 3)}"
  depends_on             = ["aws_security_group.allow-puppet",
                            "aws_launch_configuration.cdp-launchconfig",
                            "aws_autoscaling_group.cdp-autoscaling"]

  user_data = "${data.template_file.puppet-agent.rendered}"

  tags {
    Name = "PuppetAgent"
  }
}
