resource "aws_key_pair" "my_public_ssh_key" {
    key_name = "id_rsa1"
    public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_instance" "puppet-server" {
    ami = "ami-ae7bfdb8"
    instance_type = "t2.micro"
    availability_zone = "${var.AVAILABILITY_ZONE}"
    root_block_device {
      volume_size = "12"
      delete_on_termination = true
    }
    vpc_security_group_ids = ["${aws_security_group.puppet-server.id}"]
    key_name = "${aws_key_pair.my_public_ssh_key.key_name}"
    # connection {
    #   user = "${var.INSTANCE_USERNAME}"
    # }
    depends_on = ["aws_security_group.puppet-server"]
    user_data = "${file("server_install.sh")}"
    tags {
      Name = "PuppetServer"
    }
}

data "template_file" "puppet-agent" {
  template = "${file("agent_install.sh")}"
  vars {
    dns_name = "${aws_instance.puppet-server.public_dns}"
  }
}

resource "aws_instance" "puppet-agent" {
    ami = "ami-ae7bfdb8"
    instance_type = "t2.micro"
    availability_zone = "${var.AVAILABILITY_ZONE}"
    root_block_device {
      volume_size = "8"
      delete_on_termination = true
    }
    vpc_security_group_ids = ["${aws_security_group.puppet-agent.id}"]
    key_name = "${aws_key_pair.my_public_ssh_key.key_name}"
    # connection {
    #   user = "${var.INSTANCE_USERNAME}"
    # }
    depends_on = ["aws_security_group.puppet-agent"]
    #user_data = "${file("agent_install.sh")}"
    user_data = "${data.template_file.puppet-agent.rendered}"
    tags {
      Name = "PuppetAgent"
    }
}

resource "aws_security_group" "puppet-server" {
    name = "ASG-for-PuppetServer"
    ingress {
      from_port = "${var.SSH-PORT}"
      to_port = "${var.SSH-PORT}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = "${var.PUPPET-PORT}"
      to_port = "${var.PUPPET-PORT}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
      Name = "ASG-for-PuppetServer"
    }
}

resource "aws_security_group" "puppet-agent" {
    name = "ASG-for-PuppetAgent"
    ingress {
      from_port = "${var.SSH-PORT}"
      to_port = "${var.SSH-PORT}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
      Name = "ASG-for-PuppetAgent"
    }
}

output "puppet_server_dns" {
  value = "${aws_instance.puppet-server.public_dns}"
}
output "puppet_agent_public_dns" {
  value = "${aws_instance.puppet-agent.public_dns}"
}
