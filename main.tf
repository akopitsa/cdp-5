# ROOT - MAIN TF

terraform {
  backend "s3" {
    bucket  = "cdp-terraform-task"
    key     = "terraform.tfstate" 
    region  = "us-east-1"
    encrypt = true
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "cdp-terraform-task"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
    region = "${var.region}"
#    access_key = "${var.aws_access_key}"
#    secret_key = "${var.aws_secret_key}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
module "vpc" {
  source = "./modules/vpc"
}
module "nat" {
  source = "./modules/nat"
  vpc_id = "${module.vpc.vpc_id}"
  subnet-id = "${module.vpc.subnet-id}"
  count_number = "${module.vpc.count_number}"
}
module "server" {
  source = "./modules/server"
  subnet-id = "${module.nat.subnet-id}"
  vpc_id = "${module.vpc.vpc_id}"
  dns_name = "${module.elb.ELB}"
  elb-name =  "${module.elb.elb-name}"
  elb_sg_id = "${module.elb.elb_sg_id}"
}
module "elb" {
  source = "./modules/elb"
  vpc_id = "${module.vpc.vpc_id}"
  subnet-id = "${module.vpc.subnet-id}"
}
