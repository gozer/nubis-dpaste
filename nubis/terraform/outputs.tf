output "url" {
    value = "${aws_elb.dpaste.dns_name}"
}
output "instance" {
    value = "${var.ssh_user}@${aws_instance.dpaste.public_dns}"
}
