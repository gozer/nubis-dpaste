#resource "atlas_artifact" "nubis-dpaste" {
#  count = "${var.enabled}"
#  name = "nubisproject/nubis-dpaste"
#  type = "amazon.image"
#
#  lifecycle { create_before_destroy = true }
#
#  metadata {
#        project_version = "${var.version}"
#    }
#}

# Configure the AWS Provider
provider "aws" {
    profile = "${var.aws_profile}" 
    region = "${var.region}"
}

# Create a new load balancer
resource "aws_elb" "dpaste" {
  count = "${var.enabled}"
  name = "dpaste-elb-${var.project}"
  subnets = ["${split(",", var.public_subnets)}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 10
    target = "HTTP:80/"
    interval = 30 
  }

  cross_zone_load_balancing = true

  security_groups = [
    "${aws_security_group.elb.id}"
  ]
    
  tags = {
    Region = "${var.region}"
    Environment = "${var.environment}"
    TechnicalContact = "${var.technical_contact}"
  }
}

resource "aws_security_group" "elb" {
  count = "${var.enabled}"
  name = "dpaste-elb-${var.project}"
  description = "Allow inbound traffic for dpaste ${var.project}"

  vpc_id = "${var.vpc_id}"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Region = "${var.region}"
    Environment = "${var.environment}"
    TechnicalContact = "${var.technical_contact}"
  }
}

resource "aws_security_group" "dpaste" {
  count = "${var.enabled}"
  name = "dpaste-${var.project}"
  description = "Allow inbound traffic for dpaste ${var.project}"

  vpc_id = "${var.vpc_id}"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      security_groups = [
       "${aws_security_group.elb.id}"
      ]
  }
  
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      security_groups = [
        "${var.ssh_security_group_id}"
      ]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Region = "${var.region}"
    Environment = "${var.environment}"
    TechnicalContact = "${var.technical_contact}"
  }
}

resource "aws_autoscaling_group" "dpaste" {
  count = "${var.enabled}"
  vpc_zone_identifier = ["${split(",", var.private_subnets)}"]

  # This is on purpose, when the LC changes, will force creation of a new ASG
  name = "dpaste-${var.project} - ${aws_launch_configuration.dpaste.name}"
  
  load_balancers = [
   "${aws_elb.dpaste.name}"
  ]

  max_size = "2"
  min_size = "0"
  health_check_grace_period = 3000
  health_check_type = "ELB"
  desired_capacity = "1"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.dpaste.name}"

  tag {
    key = "Name"
#    value = "Dpaste server for ${var.project} (${atlas_artifact.nubis-dpaste.metadata_full.project_version})"
    value = "Dpaste server for ${var.project}"
    propagate_at_launch = true
  }
  tag {
    key = "TechnicalContact"
    value = "${var.technical_contact}"
    propagate_at_launch = true
  }

}

resource "aws_launch_configuration" "dpaste" {
  count = "${var.enabled}"

    # Somewhat nasty, since Atlas doesn't have an elegant way to access the id for a region
    # the id is "region:ami,region:ami,region:ami"
    # so we split it all and find the index of the region
    # add on, and pick that element
#    image_id = "${ element(split(",",replace(atlas_artifact.nubis-dpaste.id,":",",")) ,1 + index(split(",",replace(atlas_artifact.nubis-dpaste.id,":",",")), var.region)) }"
    image_id = "${var.ami_id}"

    instance_type = "m3.medium"
    key_name = "${var.key_name}"
    security_groups = [
      "${aws_security_group.dpaste.id}",
      "${var.internet_security_group_id}",
      "${var.shared_services_security_group_id}",
      "${var.ssh_security_group_id}",
    ]
    iam_instance_profile = "${aws_iam_instance_profile.dpaste.name}"

    user_data = <<EOF
NUBIS_ACCOUNT=${var.account_name}
NUBIS_PROJECT=${var.project}
NUBIS_ENVIRONMENT=${var.environment}
NUBIS_STACK=${var.project}
NUBIS_DOMAIN=${var.nubis_domain}
NUBIS_MIGRATE=1
NUBIS_PURPOSE=web-server
EOF

}

resource "aws_route53_record" "dpaste" {
  count = "${var.enabled}"
  zone_id = "${var.zone_id}"
  name = "dpaste.${var.project}.${var.environment}"
  type = "CNAME"
  ttl = "30"
  records = ["dualstack.${aws_elb.dpaste.dns_name}"]
}

resource "aws_iam_instance_profile" "dpaste" {
  count = "${var.enabled}"
    name = "dpaste-${var.project}-${var.environment}-${var.region}"
    roles = [
      "${aws_iam_role.dpaste.name}",
    ]
}

resource "aws_iam_role" "dpaste" {
  count = "${var.enabled}"
    name = "dpaste-${var.project}-${var.environment}-${var.region}"
    path = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
