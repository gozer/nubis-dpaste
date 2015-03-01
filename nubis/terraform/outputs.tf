output "url" {
    value = "${aws_elb.dpaste.dns_name}"
}
output "instance" {
    value = "${var.ssh_user}@${aws_instance.dpaste.public_dns}"
}
output "migrator" {
    value = "${var.ssh_user}@${aws_instance.migrator.public_dns}"
}
