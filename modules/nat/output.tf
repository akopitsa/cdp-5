## NAT OUTPUT TF

output "subnet-id" {
  value = ["${aws_subnet.main-private.*.id}"]
}
