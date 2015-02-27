# Configure the Consul provider
provider "consul" {
    address    = "${var.consul}:8500"
    datacenter = "${var.region}"
}

# Consul outputs
resource "consul_keys" "dpaste" {
    datacenter = "${var.region}"
   
    # Set the CNAME of our load balancer as a key
    key {
        name  = "elb_cname"
        path  = "aws/${var.project}/url"
        value = "http://${aws_elb.dpaste.dns_name}/"
    }
    
    # Set the instance id for our app
    key {
        name  = "instance-id"
        path  = "aws/${var.project}/instance-id"
        value = "${aws_instance.dpaste.id}"
    }

    key {
        name  = "db_name"
	path  = "${var.project}/${var.environment}/config/db_name"
	value = "${var.project}"
    }
    key {
        name  = "db_username"
	path  = "${var.project}/${var.environment}/config/db_username"
	value = "${var.project}"
    }
    key {
        name  = "app_db_server"
	path  = "${var.project}/${var.environment}/config/app_db_server"
	value = "${aws_instance.dpaste.private_dns}"
    }

    #XXX: Needs to be auto-generated
    key {
        name  = "db_password"
	path  = "${var.project}/${var.environment}/config/db_password"
	value = "cinwaSweu"
    }

    #XXX: Needs to be auto-generated
    key {
        name  = "db_root_password"
	path  = "${var.project}/${var.environment}/config/db_root_password"
	value = "TygwievNu"
    }

    #XXX: Needs to be auto-generated
    key {
        name  = "app_secret_key"
	path  = "${var.project}/${var.environment}/config/app_secret_key"
	value = "a88385f6-0b75-4d46-a420-4427297f52d5"
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
    name = "${var.environment}-${var.project}-elb-${var.release}-${var.build}"
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c" ]

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
    ami = "${var.ami}"

    tags {
        Name = "${var.project} ${var.environment} v${var.release}.${var.build}"
    }
    
    key_name = "${var.key_name}"
    
    instance_type = "m3.medium"
    
    security_groups = [
        "${aws_security_group.dpaste.name}"
    ]
    
    user_data = "NUBIS_ENVIRONMENT=${var.environment}\nCONSUL_PUBLIC=1\nCONSUL_DC=${var.region}\nCONSUL_SECRET=${var.consul_secret}\nCONSUL_JOIN=${var.consul}"
}

# Create a migration instance
resource "aws_instance" "migrator" {
    ami = "${var.ami}"

    # Cant run a migration if everything isn't ready for us
    depends_on = ["consul_keys.dpaste", "aws_instance.dpaste"]

    tags {
        Name = "${var.project} migrator ${var.environment} v${var.release}-${var.build}"
    }

    key_name = "${var.key_name}"

    instance_type = "m3.medium"

    security_groups = [
        "${aws_security_group.dpaste.name}"
    ]

    provisioner "remote-exec" {
        connection {
          user = "${var.ssh_user}"
          key_file = "${var.key_path}"
        }
        inline = [
	  "sudo -E python /var/www/dpaste/manage.py syncdb --migrate",
	  "sudo poweroff"
        ]
    }

    user_data = "NUBIS_ENVIRONMENT=${var.environment}\nCONSUL_PUBLIC=1\nCONSUL_DC=${var.region}\nCONSUL_SECRET=${var.consul_secret}\nCONSUL_JOIN=${var.consul}"
}

resource "aws_security_group" "dpaste" {
  name        = "${var.environment}-dpaste-${var.release}-${var.build}"
  description = "Allow inbound traffic for ${var.project}"

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
  
  ingress {
      from_port   = 8300
      to_port     = 8303
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 8300
      to_port     = 8303
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
