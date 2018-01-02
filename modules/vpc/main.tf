# VPC MAIN TF

data "aws_availability_zones" "az_available" {}

resource "aws_vpc" "main" {
  cidr_block           = "${var.aws_vpc_cidr_block}"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags {
    Name = "MyMainVPC"
  }
}

# Subnets
resource "aws_subnet" "main-public" {
  count                   = "${var.number_of_azs}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.vpc_net_prefix}${count.index+1}${var.vpc_net_postfix}"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.az_available.names[count.index]}"

  tags {
    Name = "MyMain-public-${count.index}"
  }
}


# Internet GW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "MyMainGW"
  }
}
# route tables
resource "aws_route_table" "main-public" {
  vpc_id = "${aws_vpc.main.id}"
  depends_on = ["aws_subnet.main-public"]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-gw.id}"
  }

  tags {
    Name = "MyMain-PublicRT"
  }
}


# route associations public
resource "aws_route_table_association" "main-public" {
  count                   = "${var.number_of_azs}"
  #subnet_id      = "${aws_subnet.main-public-1.id}"
  depends_on  = ["aws_route_table.main-public"]
  subnet_id      = "${aws_subnet.main-public.*.id[count.index]}"
  route_table_id = "${aws_route_table.main-public.id}"
}


//===================================================
