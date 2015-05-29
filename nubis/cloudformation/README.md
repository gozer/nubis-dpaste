## Commands to work with CloudFormation

NOTE: All examples run from the top level project directory.

You need to create a parameters.json file. You can use parameters.json-dist as an template.

To create a new stack:
```bash
aws cloudformation create-stack --stack-name nubis-dpaste --template-body file://nubis/cloudformation/main.json --parameters file://nubis/cloudformation/parameters.json
```

To update and existing stack:
```bash
aws cloudformation update-stack --stack-name nubis-dpaste --template-body file://nubis/cloudformation/main.json --parameters file://nubis/cloudformation/parameters.json
```

After creating or updating a stack you might need to update Consul. Run this command to take any (properly described) Cloudformation outputs and insert or update them in Consul:
```bash
nubis-consul --stack-name nubis-dpaste --settings nubis/cloudformation/parameters.json get-and-update
```

To get the list of nameservers for the HostedZone:
```bash
nubis-consul --stack-name nubis-dpaste get-route53-nameservers
```

To delete the stack:
```bash
aws cloudformation delete-stack --stack-name nubis-dpaste
```

After deleting the stack, be sure to remove the Consul data"
```bash
nubis-consul --stack-name nubis-dpaste --settings nubis/cloudformation/parameters.json delete
```

#### Nested Stacks

We are using nested stacks to deploy the necessary resources. You can find the nested stack templates at [nubis-stacks](https://github.com/Nubisproject/nubis-stacks).
