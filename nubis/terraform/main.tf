# Configure the Consul provider
provider "consul" {
    address    = "${var.consul}:8500"
    datacenter = "${var.region}"
}

#resource "consul_keys" "app" {
#    # Get the base AMI id from Consul
#    key {
#        name = "ami"
#        path = "nubis/base/releases/${var.base_release}.${var.base_build}/${var.region}"
#    }
#}

# Consul outputs
resource "consul_keys" "dpaste" {
    datacenter = "${var.region}"
   
    # Set the CNAME of our load balancer as a key
    key {
        name  = "elb_cname"
        path  = "aws/dpaste/url"
        value = "http://${aws_elb.dpaste.dns_name}/"
    }
    
    key {
        name  = "instance-id"
        path  = "aws/dpaste/instance-id"
        value = "${aws_instance.dpaste.id}"
    }
}

# Configure the AWS Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "${var.region}"
}

# Create a new load balancer
resource "aws_elb" "dpaste" {
    name = "dpaste-elb"
    availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c" ]

    listener {
        instance_port     = 8080
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        target              = "HTTP:8080/"
        interval            = 30
    }

    instances = ["${aws_instance.dpaste.id}"]
    cross_zone_load_balancing = true
}

# Create a web server
resource "aws_instance" "dpaste" {
#    ami = "${consul_keys.app.var.ami}"
    ami = "ami-85e5beb5"
    
    tags {
        Name = "Jd Dpaste Test"
    }
    
    key_name = "${var.key_name}"
    
    instance_type = "m3.medium"
    
#    iam_instance_profile = "${var.iam_instance_profile}"
    
    security_groups = [
        "${aws_security_group.dpaste.name}"
    ]
    
    user_data = "CONSUL_PUBLIC=1\nCONSUL_DC=${var.region}\nCONSUL_SECRET=${var.consul_secret}\nCONSUL_JOIN=${var.consul}"
}

resource "aws_security_group" "dpaste" {
  name        = "dpaste"
  description = "Allow inbound traffic for dpaste"

  ingress {
      from_port   = 0
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
      from_port   = 0
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
      from_port   = 0
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}