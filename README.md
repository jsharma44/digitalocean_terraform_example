# DigitalOcean Terraform Example

Heres is the scenario we want to create a project if not exists and for some data center regions we want to create droplets,managed database clusters, vpc, vpc peering, assign reserved/floating ip to droplets and want to create monitoring alerts for cpu,ram and disk utilization via slack and email channel.

## Perquisites

1. [Terraform installed](https://developer.hashicorp.com/terraform/install)
2. [Doctl installed](https://docs.digitalocean.com/reference/doctl/how-to/install/)
3. [DigitalOcean Account](https://m.do.co/c/bc188df73530)
4. Get Your DO account token
5. For VPC peering you need to enable that in your DigitalOcean account settings
6. You may need to connect with DO support team if you see error while assigning reserved ips.

## How To Run

1. first clone this repository or download it
2. cd to repository and edit in vscode or any editor
3. adjust your configuration in terraform.tfvars
4. open terminal in current directory and run following commands

```bash

terraform init
terraform apply | tee terraform_apply.log

```
