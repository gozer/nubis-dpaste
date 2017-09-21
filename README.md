# nubis-dpaste

[![Version](https://img.shields.io/github/release/nubisproject/nubis-dpaste.svg?maxAge=2592000)](https://github.com/nubisproject/nubis-dpaste/releases)
[![Build Status](https://img.shields.io/travis/nubisproject/nubis-dpaste/master.svg?maxAge=2592000)](https://travis-ci.org/nubisproject/nubis-dpaste)
[![Issues](https://img.shields.io/github/issues/nubisproject/nubis-dpaste.svg?maxAge=2592000)](https://github.com/nubisproject/nubis-dpaste/issues)

This is a Nubis deployment of the [dpaste](https://github.com/bartTC/dpaste)
application. The purpose of this project is to demonstrate an example of a
django / python deployment. This repository is an example of a "deployment
repository", in other words a repository that does not contain any application
code.

## Repository Structure

The structure of the repository is quite simple. The application is installed
as a git submodule. There is a directory called *nubis* which contains all of
the bits necessary to deploy the application.

## Deployment Process

Currently there are two steps necessary to deploy this project. While these
steps are listed in order to build and deploy, it is typically not necessary to
run the build steps. This means you can skip the [Nubis Builder](#nubis-builder)
bits and jump straight to the [Terraform](#terraform) section.

### Puppet

We are using [puppet](http://puppetlabs.com/) in this example to bootstrap up
our instance. Puppet installs and configures services such as *Apache* and
*MySQL*. We are using the
[nubis-puppet](https://github.com/Nubisproject/nubis-puppet) project for our
module collection. This is conveniently installed on the *base image* (built by
[nubis-base](https://github.com/Nubisproject/nubis-base)) that we are going to
use as the starting image for our Packer build in the next step. This means that
there is nothing for you to do here, however you should be aware of this for
when you deploy your own applications.

### Nubis Builder

[Nubis Builder](https://github.com/Nubisproject/nubis-builder) is the piece
that will build our Amazon Machine Image (AMI). It is made up of a two pieces:

1. The [main.json](nubis/builder/provisioners.json) file which:
    * Contains one or more *provisioners* statements for calling
      any bootstrapping commands for the application
    * Invokes a puppet standalone run through nubis-builder
    * Invokes a *builders* statement describing where to build the AMI, also
      run through nubis-builder
2. A [project.json](nubis/builder/project.json) file which contains settings
   for nubis-builder

To run nubis-builder, from the repository root you first need to ensure that
you have installed the
[prerequisites](https://github.com/Nubisproject/nubis-docs/blob/master/
PREREQUISITES.md) and
[nubis-builder](https://github.com/Nubisproject/nubis-builder#builder-quick-
start). After which you simply call nubis-builder like so:

```bash
nubis-builder build
```

This takes around *8m7.350s* to complete.

### Terraform

The next step is to take the shiny new AMI that nubis-builder built and deploy
it. This is where [Terraform](http://terraform.io) comes into play. Terraform is
our infrastructure deployment framework, and it's a fantastic tool for the job.
All in all, it consists of only a few files:

1. [terraform.tfvars-dist](nubis/terraform/terraform.tfvars-dist) simply lists
   the inputs you will need to provide
2. [main.tf](nubis/terraform/main.tf) is where the real heavy lifting takes
   place. This is where you describe your infrastructure. Things like worker
   pools, load balancers, DNS and so on.
3. [outputs.tf](nubis/terraform/outputs.tf) is where you can define handy
   outputs from your deployment, like the final URL of the deployed application.
4. [consul.tf](nubis/terraform/consul.tf) is where you can define the
   infrastructure settings your app needs access to.
5. [README.md](nubis/terraform/README.md) contains some handy cut-and-paste
   cheat-sheet style commands for your future reference.

To get ready to execute Terraform, first change your current directory to the
[terraform/](nubis/terraform/) directory and set an account name variable:

```bash
cd nubis/terraform
export ACCOUNT_NAME='some-account-name'
```

Then, to execute Terraform, you first need to create your *terraform.tfvars*
file, for which there is a template provided (terraform.tfvars-dist). After
which you will execute Terraform.

NOTE: You will likely need to change the *service_name* from
*dpaste-\<username>* to something unique as each deployment requires a unique
name.

Also, if you skipped the build step above you can use the pre-built AMIs to
deploy with:

* **us-east-1**: ami-201c5337
* **us-west-2**: ami-cfc51daf

#### Terraform Get

Terraform makes heavy uses of modules, and before we can successfully deploy an
application with it, we need it to first download the modules it needs

```bash
$> terraform get -update=true
Get: git::https://github.com/nubisproject/nubis-terraform.git?ref=master (update)
Get: git::https://github.com/nubisproject/nubis-terraform.git?ref=master (update)
Get: git::https://github.com/nubisproject/nubis-terraform.git?ref=master (update)
Get: git::https://github.com/nubisproject/nubis-terraform.git?ref=master (update)
Get: git::https://github.com/nubisproject/nubis-terraform.git?ref=master (update)
```

#### Terraform Plan

Now, we are ready to plan our deployment. In terraform parlance, this means
just previewing all the steps necessary to achieve the deployment we have
specified, without actually making any changes to the infrastructure yet.

```bash
$> CONSUL_HTTP_SSL_VERIFY=0 aws-vault exec ${ACCOUNT_NAME}-admin -- terraform plan
2016/09/20 11:58:04 Parsing config file /home/gozer/.aws/config
2016/09/20 11:58:04 Looking up keyring for nubis-lab
2016/09/20 11:58:04 Using session ****************XXXX, expires in 55m30.765625184s
2016/09/20 11:58:04 Assuming role arn:aws:iam::XXXXXXXXXX:role/nubis/admin/gozer
2016/09/20 11:58:04 Using role ****************YYYY, expires in 14m59.434980674s
2016/09/20 11:58:04 Parsing config file /home/gozer/.aws/config
Refreshing Terraform state prior to plan...

module.database.info.terraform_remote_state.info: Refreshing state... (ID: ...
module.dns.info.terraform_remote_state.info: Refreshing state... (ID: ...
module.worker.info.terraform_remote_state.info: Refreshing state... (ID: ...
module.load_balancer.info.terraform_remote_state.info: Refreshing state... (ID:
[...]
-/+ module.worker.aws_autoscaling_group.asg
[...]
-/+ module.worker.aws_autoscaling_policy.down
[...]
-/+ module.worker.aws_autoscaling_policy.up
[...]
~ module.worker.aws_cloudwatch_metric_alarm.down
[...]
~ module.worker.aws_cloudwatch_metric_alarm.up
[...]
-/+ module.worker.aws_launch_configuration.launch_config
[...]

Plan: 4 to add, 2 to change, 4 to destroy.Plan: 4 to add, 2 to change, 4 to destroy.
```

A few important things of note here, for completeness.

First, notice **CONSUL_HTTP_SSL_VERIFY=0**, this is an unfortunate side-effect
of not yet being able to verify the SSL certificate of the Consul endpoint, and
is especially annoying for developer launches, as it can't be set anywhere but
in the environemnt at the moment. Save yourself some trouble in the future and
stick it somewhere in your *~/.bash_profile*

Second, for security, we've wrapped the invocation of Terraform with aws-vault,
so we don't have to directly manage or manipulate AWS credentials.

Third, we could also have passed in variables with the -var argument, instead
of in the variables file. Command-line arguments take precedence over the
contents of the file. So to plan for a new AMI, we could have instead done:

```bash
$> terraform plan -var ami=ami-XYZ123
```

And finally, the output of Terraform's plan shows precisely what steps will be
taken, and they are quite human parseable. In this example, for instance, we can
see this deploy will change an autoscaling group, a launch configuration, and
some associated autoscaling policies and cloudwatch alarms.

Nothing has happened yet.

#### Terraform Apply

Now that we have reviewed the proposed changes, we can apply them with:

```bash
$> CONSUL_HTTP_SSL_VERIFY=0 aws-vault exec ${ACCOUNT_NAME}-admin -- terraform apply
2016/09/20 11:58:04 Parsing config file /home/gozer/.aws/config
2016/09/20 11:58:04 Looking up keyring for nubis-lab
2016/09/20 11:58:04 Using session ****************XXXX, expires in 55m30.765625184s
2016/09/20 11:58:04 Assuming role arn:aws:iam::XXXXXXXXXX:role/nubis/admin/gozer
2016/09/20 11:58:04 Using role ****************YYYY, expires in 14m59.434980674s
2016/09/20 11:58:04 Parsing config file /home/gozer/.aws/config
Refreshing Terraform state prior to plan...

module.database.info.terraform_remote_state.info: Refreshing state... (ID: ...
module.dns.info.terraform_remote_state.info: Refreshing state... (ID: ...
[...]
module.worker.aws_launch_configuration.launch_config: Creating...
module.worker.aws_launch_configuration.launch_config: Creation complete
module.worker.aws_autoscaling_group.asg: Creating...
module.worker.aws_autoscaling_group.asg: Still creating... (10s elapsed)
module.worker.aws_autoscaling_group.asg: Still creating... (20s elapsed)
module.worker.aws_autoscaling_group.asg: Creation complete
module.worker.aws_cloudwatch_metric_alarm.up: Modifying...
module.worker.aws_cloudwatch_metric_alarm.down: Modifying...
module.worker.aws_autoscaling_group.asg: Destroying...
[...]
Apply complete! Resources: 4 added, 2 changed, 4 destroyed.

Outputs:

  address = https://www.dpaste-<username>.<env>.<env>.<region>.<account>.allizom.org/
```

And we can see here that all is well, some resources got modified, while others
got created and destroyed. In the end,  we see the outputs provided by our
deployment.

## Quick Commands

```bash
git clone https://github.com/mozilla/nubis-dpaste.git

git submodule update --init --recursive

nubis-builder build

*Edit nubis/terraform/terraform.tfvars

cd nubis/terraform

export ACCOUNT_NAME='some-account-name'

* Download/update TF modules
terraform get -update=true

* Preview proposed changes
CONSUL_HTTP_SSL_VERIFY=0 aws-vault exec ${ACCOUNT_NAME}-admin -- terraform plan

*Apply proposed changes
CONSUL_HTTP_SSL_VERIFY=0 aws-vault exec ${ACCOUNT_NAME}-admin -- terraform apply

```
