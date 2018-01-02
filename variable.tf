# ROOT VARIABLES TF

variable "region" {
  default = "us-east-1"
}
variable "key_name" {
  default = "id_rsa1"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}
#variable "aws_access_key" {}
#variable "aws_secret_key" {}
