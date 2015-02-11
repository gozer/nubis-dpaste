variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "amis" {
    default = {
        us-east-1 = "ami-a26f27ca"
        us-west-2 = "ami-15f7d225"
    }
}

variable "consul" {
  description = "URL to Consul"
  default = "127.0.0.1"
}

variable "consul_secret" {
  description = "Security shared secret for consul membership (consul keygen)"
}

variable "region" {
  default = "us-east-1"
  description = "The region of AWS, for AMI lookups."
}

variable "project" {
  default = "dpaste"
  description = "Name of the project"
}

variable "release" {
  default = "0"
  description = "Release number of the architecture"
}

variable "build" {
  default = "10"
  description = "Build number of the architecture"
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}
