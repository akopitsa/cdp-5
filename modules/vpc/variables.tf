# VPC VARIABLES TF

variable "aws_vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "vpc-private-net" {
  default = "-private-"
}
variable "vpc-public-net" {
  default = "-public-"
}
variable "region" {
  default = "us-east-1"
}
variable "number_of_azs" {
    default = "3"
}
variable "vpc_net_prefix" {
  default = "10.0."
}
variable "vpc_net_postfix" {
  default = ".0/24"
}
