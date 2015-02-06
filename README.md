# nubis-dpaste
This is a nubis deployment of the dpaste app. This is intended to be an example of a django / python deployment.

TODO:
    Auto-generate secrets
    Integrate secrets with proper storage location (Consul?)
    Generate useful Terraform outputs for Consul
    Integrate with nubis-ci
    Write documentation to explain how everything is glued together
    Investigate method to simplify the deployment process
    Dress up consuming Packer builds (AMIs) with Terraform (AKA stop hardcoding AMI IDs)
    Fix Terraform main.tf IAM id (requires Consul integration)
    Research Terraform work flow patterns

How it works:
Call packer to build the image (AMI)
    Has file called main.json
    Has a builder section for building the ami
    has one or more provisioner sections for calling puppet and possibly bootstrapping the application
Contains a puppet section that
    Installs necessary things from the librarian-puppet repository
    Has an init.pp which includes modules from librarian-puppet and describes the application.
    Contains a .pp file for everything consumed from librarian-puppet
Call terraform that:
    Creates the AWS resources necessary to run the application
    At a minimum this is an instance, ssh keys, elastic IPs, etc...


Basic Commands:
packer build -var-file=nubis/packer/variables.json -var release=0 -var build=1 nubis/packer/main.json
11m 18.488s

terraform plan -var-file=nubis/terraform/terraform.tfvars nubis/terraform/
terraform apply -var-file=nubis/terraform/terraform.tfvars nubis/terraform/
0m 35.162s
