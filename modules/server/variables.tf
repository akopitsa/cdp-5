variable "key_name" {
  default = "id_rsa1"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "AMI" {
# ubuntu 16 ami-aa2ea6d0
# centos 7 ami-ae7bfdb8  
  default = "ami-ae7bfdb8"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "AMIS" {
  type = "map"

  default = {
    us-east-1 = "ami-aa2ea6d0"
  }
}

variable "AWS_REGION" {
  default = "us-east-1"
}
variable "subnet-id" {
  type = "list"
}
variable "vpc_id" {}
variable "dns_name" {}
variable "elb-name" {}
variable "elb_sg_id" {}
