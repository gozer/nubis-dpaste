# nubis-dpaste
This is a Nubis deployment of the [dpaste](https://github.com/bartTC/dpaste) application. The purpose of this project is to demonstrate an example of a django / python deployment. This repository is an example of a "deployment repository", in other words a repository that does not contain any application code.

## Repository Structure
The structure of the repository is quite simple. The application is installed as a git submodule. There is a directory called *nubis* which contains all of the bits necessary to deploy the application.


## Deployment Process
Currently there are two steps necessary to deploy this project. While these steps are listed in order to build and deploy, it is typically not necessary to run the build steps. This means you can skip the [Nubis Builder](#nubis-builder) bits and jump straight to the [Cloudformation](#cloudformation) section.


### Puppet
We are using [puppet](http://puppetlabs.com/) in this example to bootstrap up our instance. Puppet installs and configures services such as *Apache* and *MySql*. We are using the [nubis-puppet](https://github.com/Nubisproject/nubis-puppet) project for our module collection. This is conveniently installed on the *base image* (built by [nubis-base](https://github.com/Nubisproject/nubis-base)) that we are going to use as the starting image for our Packer build in the next step. This means that there is nothing for you to do here, however yo should be aware of this for when you deploy your own applications.


### Nubis Builder
[Nubis Builder](https://github.com/Nubisproject/nubis-builder) is the piece that will build our Amazon Machine Image (AMI). It is made up of a two pieces:

1. The [main.json](nubis/builder/provisioners.json) file which:
    * Contains one or more *provisioners* statements for calling  any bootstrapping commands for the application
    * Invokes a puppet standalone run through nubis-builder
    * Invokes a *builders* statement describing where to build the AMI, also run through nubis-builder
2. A [project.json](nubis/builder/project.json) file which contains settings for nubis-builder

To run nubis-builder, from the repository root you first need to ensure that you have installed the [prerequisites](https://github.com/Nubisproject/nubis-docs/blob/master/PREREQUISITES.md) and [nubis-builder](https://github.com/Nubisproject/nubis-builder#builder-quick-start). After which you simply call nubis-builder like so:
```bash
nubis-builder build
```
This takes around *8m7.350s* to complete.


### Cloudformation
The next step is to take the shiny new AMI that nubis-builder built and deploy it. This is where [Cloudformation](http://aws.amazon.com/cloudformation/) comes into play. Cloudformation is our infrastructure deployment framework, but not to worry it is really not as complicated as its name implies. It consists of a few files:

0. [parameters.json-dist](nubis/cloudformation/parameters.json-dist) simply lists the inputs you will need to provide
0. [main.json](nubis/cloudformation/main.json) is where the real heavy lifting takes place. This is where you describe your infrastructure. Things like EC2 instances, security groups, ELBs and so on.
0. [README.md](nubis/cloudformation/README.md) contains some handy cut-and-paste cheat-sheet style commands for your future reference.


To execute Cloudformation, from the repository root you first need to create your *parameters.json* file, for which there is a template provided (parameters.json-dist). After which you will execute Cloudformation.

NOTE: You will likely need to change the *stack-name* from *dpaste-xxx* to something unique as each stack requires a unique name.

Also, if you skiped the build step above you can use the pre-built ami *ami-7bbb844b* to deploy with.

To launch your stack:
```bash
aws cloudformation create-stack --template-body file://nubis/cloudformation/main.json --parameters file://nubis/cloudformation/parameters.json --stack-name dpaste-xxx
```
This takes around *6m 30s*, which you can see is not exactly speedy (mostly due to Route53 in this case).

Once you are finished with your app you will likely wish to delete it and clear the consul data:
```bash
aws cloudformation delete-stack --stack-name dpaste-xxx

nubis-consul --stack-name dpaste-xxx --settings nubis/cloudformation/parameters.json delete
```

## Quick Commands

```bash
git clone https://github.com/mozilla/nubis-dpaste.git

git submodule update --init --recursive

nubis-builder build

*Edit nubis/cloudformation/parameters.json*

aws cloudformation create-stack --template-body file://nubis/cloudformation/main.json --parameters file://nubis/cloudformation/parameters.json --stack-name dpaste-xxx

aws cloudformation delete-stack --stack-name dpaste-xxx

nubis-consul --stack-name dpaste-xxx --settings nubis/cloudformation/parameters.json delete
```
