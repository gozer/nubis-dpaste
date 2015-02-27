variable "aws_access_key" {}
variable "aws_secret_key" {}

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

variable "key_path" {
  description = "Path to the decrypted secret key for key_name"
}

variable "ssh_user" {
  description = "User to use for ssh access"
}

variable "environment" {
  description = "Name of the environment this deployment is for"
  default = "sandbox"
}
