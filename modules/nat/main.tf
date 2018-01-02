# MAIN TF NAT MODULE

data "aws_availability_zones" "az_available" {}
#   #route tables for private
resource "aws_route_table" "main-private" {
  vpc_id = "${var.vpc_id}"
  #depends_on = "${aws_instance.nat-instance}"
  route {
    cidr_block = "0.0.0.0/0"

    #instance_id = "${aws_instance.nat-instance.id}"
    instance_id = "${aws_instance.nat-instance.id}"
  }

  tags {
    Name = "MyMain-PrivateRT"
  }
}
resource "aws_subnet" "main-private" {
  count                   = "${var.count_number}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.vpc_net_prefix}${count.index+4}${var.vpc_net_postfix}"
  #map_public_ip_on_launch = "true"
  #availability_zone       = "us-east-1a"
  availability_zone = "${data.aws_availability_zones.az_available.names[count.index]}"

  tags {
    Name = "MyMain-private-${count.index}"
  }
}

resource "aws_route_table_association" "main-private" {
  count                   = "${var.count_number}"
  #subnet_id      = "${aws_subnet.main-public-1.id}"
  depends_on  = ["aws_route_table.main-private"]
  subnet_id      = "${aws_subnet.main-private.*.id[count.index]}"
  route_table_id = "${aws_route_table.main-private.id}"
}


resource "aws_instance" "nat-instance" {
  ami                         = "ami-184dc970"
  instance_type               = "t2.micro"
  key_name                    = "${var.key_name}"
  depends_on                  = ["aws_security_group.for-nat-instance"]
  subnet_id                   = "${element(var.subnet-id, 0)}"
  vpc_security_group_ids      = ["${aws_security_group.for-nat-instance.id}"]
  source_dest_check           = false
  associate_public_ip_address = false

  root_block_device {
    volume_size           = "8"
    delete_on_termination = true
  }

  tags {
    Name = "myNATinstance"
  }
}


resource "aws_eip" "nat" {
  instance = "${aws_instance.nat-instance.id}"
  vpc      = true
}

resource "aws_security_group" "for-nat-instance" {
  #count                   = "${var.count_number}"
  //vpc_id      = "${aws_vpc.main.id}"
  vpc_id      = "${var.vpc_id}"
  name        = "security group for-nat-instance"
  description = "security group for-nat-instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_net_prefix}4${var.vpc_net_postfix}",
                   "${var.vpc_net_prefix}5${var.vpc_net_postfix}",
                   "${var.vpc_net_prefix}6${var.vpc_net_postfix}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_net_prefix}4${var.vpc_net_postfix}",
                   "${var.vpc_net_prefix}5${var.vpc_net_postfix}",
                   "${var.vpc_net_prefix}6${var.vpc_net_postfix}"]
  }

  ingress {
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_net_prefix}4${var.vpc_net_postfix}",
                   "${var.vpc_net_prefix}5${var.vpc_net_postfix}",
                   "${var.vpc_net_prefix}6${var.vpc_net_postfix}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8140
    to_port     = 8140
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_net_prefix}4${var.vpc_net_postfix}",
                   "${var.vpc_net_prefix}5${var.vpc_net_postfix}",
                   "${var.vpc_net_prefix}6${var.vpc_net_postfix}"]
  }

  tags {
    Name = "SG-for-nat-instance"
  }
}
