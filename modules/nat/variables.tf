## NAT VARIABLES TF

variable "vpc_id" {}
variable "subnet-id" {
  type = "list"
}
variable "key_name" {
  default = "id_rsa1"
}
variable "count_number" {
  default = "4"
}
variable "vpc_net_prefix" {
  default = "10.0."
}
variable "vpc_net_postfix" {
  default = ".0/24"
}
variable "vpc-private-net" {
  default = "-private-"
}
