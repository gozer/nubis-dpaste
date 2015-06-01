# nubis-dpaste
This is a Nubis deployment of the [dpaste](https://github.com/bartTC/dpaste) application. The purpose of this project is to demonstrate an example of a django / python deployment. This repository is an example of a "deployment repository", in other words a repository that does not contain any application code.

## Repository Structure
The structure of the repository is quite simple. The application is installed as a git submodule. There is a directory called *nubis* which contains all of the nubis modules necessary to deploy the application.


## Deployment Process
Currently there are a few steps necessary to deploy this project. We intend to simplify this process going forward. While these steps are listed in order to build and deploy, it is typically not necessary to run the build steps. This means you can skip the Packer bits and jump straight to the [Terraform](#terraform) section.


### Puppet
We are using [puppet](http://puppetlabs.com/) in this example to bootstrap up our VM. Puppet installs and configures services such as *Apache* and *MySql*. We are using the [nubis-puppet](https://github.com/Nubisproject/nubis-puppet) project for our module collection. This is conveniently installed on the *base image* (built by [nubis-base](https://github.com/Nubisproject/nubis-base)) that we are going to use as the starting image for our Packer build in the next step.


### Packer
[Packer](https://www.packer.io/) is the piece that will build our AMI. It is made up of a few pieces:

1. The [main.json](nubis/packer/main.json) file which contains:
    * A *builders* statement describing where to build the AMI
    * One or more *provisioners* statements for calling puppet standalone and any bootstrapping commands for the application
2. A [variables.json](nubis/packer/variables.json-dist) file which contains things like:
    * AWS credentials
    * base AMI ID

To run packer, from the repository root you first need to create your *variables.json* file, for which there is a template provided (variables.json-dist). After which you simply call packer like so:
```bash
packer build -var-file=nubis/packer/variables.json -var release=0 -var build=1 nubis/packer/main.json
```
This takes around *11m 18.488s* to complete.


### Terraform
The next step is to take the shiny new AMI that Packer built and deploy it. This is where [Terraform](https://www.terraform.io/) comes into play. Terraform is our infrastructure deployment framework, but not to worry it is really not as complicated as its name implies. It consists of a few files:

1. [inputs.tf](nubis/terraform/inputs.tf) simply lists the variables you might need to provide
2. [main.tf](nubis/terraform/main.tf) is where the real heavy lifting takes place. This is where you describe your infrastructure. Thisgs like EC2 instances, security groups, ELBs and so on.
3. [outputs.tf](nubis/terraform/outputs.tf) describes what information from the build we want to make available (via Consul) for later reference.
4. [terraform.tfvars](nubis/terraform/terraform.tfvars-dist) is where you will set your AWS credentials and such.

To run terraform, from the repository root you first need to create your *terraform.tfvars* file, for which there is a template provided (terraform.tfvars-dist). After which you simply call terraform like so:

To see what resources will be created, destroyed, or refreshed:
```bash
terraform plan -var-file=nubis/terraform/terraform.tfvars nubis/terraform/
```
To apply the plan (do the work)
```bash
terraform apply -var-file=nubis/terraform/terraform.tfvars nubis/terraform/
```
This takes around *0m 35.162s*, which you can see is quite speedy.


## Quick Commands
Edit both *nubis/packer/variables.json* and *nubis/terraform/terraform.tfvars*
```bash
git clone https://github.com/mozilla/nubis-dpaste.git

git submodule update --init --recursive

packer build -var-file=nubis/packer/variables.json -var release=0 -var build=1 nubis/packer/main.json

terraform apply -var-file=nubis/terraform/terraform.tfvars nubis/terraform/
```


## TODO
We have a lot of work to do before this project is ready for easy consumption. Some of those things are:
* Auto-generate secrets
* Integrate secrets with proper storage location (Consul?)
* Generate useful Terraform outputs for Consul
* Integrate with nubis-ci
* Investigate method to simplify the deployment process
* Dress up consuming Packer builds (AMIs) with Terraform (AKA stop hardcoding AMI IDs)
* Fix Terraform main.tf IAM id (requires Consul integration)
* Research Terraform work flow patterns
