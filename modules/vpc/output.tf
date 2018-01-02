# VPC OUTPUT TF

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
output "subnet-id" {
  value = ["${aws_subnet.main-public.*.id}"]
}
output "count_number" {
  value = "${var.number_of_azs}"
}
