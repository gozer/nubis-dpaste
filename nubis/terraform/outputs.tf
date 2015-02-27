output "url" {
    value = "${aws_elb.dpaste.dns_name}"
}
output "instance" {
    value = "ubuntu@${aws_instance.dpaste.public_dns}"
}
