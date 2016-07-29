variable "aws_profile" {}

variable "environment" {
  description = "Name of the environment this deployment is for"
  default = "stage"
}

variable "nubis_domain" {
  description = "Top-level Nubis domain for this environemnt"
  default = "nubis.allizom.org"
}

variable "enabled" {
  default = "1"
}

variable "region" {
  default = "us-west-2"
  description = "The region of AWS, for AMI lookups and where to launch"
}

variable "project" {
  description = "Name of the Nubis project"
  default = "dpaste-jd"
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

variable "zone_id" {
  description = "ID of the zone for the project"
}

variable "vpc_id" {
}

variable "internet_security_group_id" {
  description = "ID of that SG"
}

variable "shared_services_security_group_id" {
  description = "ID of that SG"
}

variable "ssh_security_group_id" {
  description = "ID of that SG"
}

variable "public_subnets" {
  description = "Public Subnets IDs, comma-separated"
}

variable "private_subnets" {
  description = "Private Subnets IDs, comma-separated"
}

variable "account_name" {
  description = "Name of the AWS account"
}

variable "version" {
  description = "Version of nubis-dpaste to deploy"
}

variable "technical_contact" { 
  default = "infra-aws@mozilla.com"
}

variable "ami_id" {
  description = "Atlas lookup not working correctly"
}