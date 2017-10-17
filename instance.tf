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
    connection {
      user = "${var.INSTANCE_USERNAME}"
    }
    depends_on = ["aws_security_group.puppet-server"]
    user_data = "${file("server_install.sh")}"
    tags {
      Name = "PuppetServer"
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
