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
3. adjust your configuration in [terraform.tfvars](./terraform.tfvars)
4. You can check default configuration in [variables.tf](./variables.tf). Following is a basic example

```bash
do_token     = "dop_vXXXXXXXXXXXXXXXXX"
project_name = "My Project"

# Droplets
droplet_name_prefix = "droplet"
droplet_size        = "s-1vcpu-1gb"
regions             = ["blr1", "ams3", "nyc3"]
droplet_image       = "ubuntu-24-04-x64"
droplet_tags        = ["cloud", "api", "docs"]

# Manged Database Clusters
database_clusters = [{
  name    = "postgres"
  engine  = "pg"
  version = "16"
  size    = "db-s-1vcpu-1gb"
  count   = 1
  },
  {
    name    = "redis"
    engine  = "redis"
    version = "7"
    size    = "db-s-1vcpu-1gb"
    count   = 1
  }
]

# Notifications
email         = "you@example.com"
slack_webhook = "https://hooks.slack.com/services/xxxx/xxxx/xxxx"



```

5. open terminal in current directory and run following commands

```bash

terraform init
terraform apply | tee terraform_apply.log

```
