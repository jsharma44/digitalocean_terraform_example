
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
provider "digitalocean" {
  token = var.do_token
}


# Fetch an existing project
data "digitalocean_project" "existing_project" {
  name = var.project_name
}

# Create the project if it doesn't exist
resource "null_resource" "create_project" {
  count = data.digitalocean_project.existing_project.id == "" ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
      doctl projects create --name ${var.project_name} --purpose "Web Application" --description "Project for ${var.project_name}"
    EOT
    environment = {
      DIGITALOCEAN_ACCESS_TOKEN = var.do_token
    }
  }
}

# create a VPC in each region
resource "digitalocean_vpc" "vpc" {
  for_each = toset(var.regions)
  name     = "vpc-${each.key}"
  region   = each.key
}

# fetch all ssh keys - if any exsisting ssh keys are there it will map to the droplets
data "digitalocean_ssh_keys" "all_keys" {}
# create a droplet in each region
resource "digitalocean_droplet" "cloud" {
  for_each = toset(var.regions)
  name     = "${var.droplet_name_prefix}-${each.key}"
  region   = each.key
  size     = var.droplet_size
  image    = var.droplet_image
  vpc_uuid = digitalocean_vpc.vpc[each.key].id
  tags     = var.droplet_tags
  ssh_keys = [for key in data.digitalocean_ssh_keys.all_keys.ssh_keys : key.id]


}

# You may needt to contact support to enable reserved IPs in your account
# https://docs.digitalocean.com/products/networking/reserved-ips/
# create a reserved IP in each region
resource "digitalocean_reserved_ip" "reserved_ip" {
  for_each = toset(var.regions)
  region   = each.key
}

# Assign the reserved IP to the droplet
resource "digitalocean_reserved_ip_assignment" "reserved_ip_assignment" {
  for_each   = toset(var.regions)
  droplet_id = digitalocean_droplet.cloud[each.key].id
  ip_address = digitalocean_reserved_ip.reserved_ip[each.key].ip_address

}

output "vpc_keys" {
  value = keys(digitalocean_vpc.vpc)
}

# Output the names of the database clusters
output "database_cluster_names" {
  value = [for cluster in var.database_clusters : cluster.name]
}

# Create database clusters based on the array of objects

locals {
  combined_clusters = flatten([
    for region in var.regions : [
      for cluster in var.database_clusters : {
        key     = "${region}-${cluster.name}"
        region  = region
        cluster = cluster
      }
    ]
  ])
}

resource "digitalocean_database_cluster" "database" {
  for_each = {
    for cluster in local.combined_clusters : cluster.key => cluster
  }

  name                 = "${each.value.cluster.name}-${each.value.region}"
  engine               = each.value.cluster.engine
  version              = each.value.cluster.version
  size                 = each.value.cluster.size
  region               = each.value.region
  node_count           = each.value.cluster.count
  private_network_uuid = digitalocean_vpc.vpc[each.value.region].id
}



# currently in alpha in some regions you may get - VPC Inter-DC Peering not enabled in region
# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/vpc_peering

# create a VPC peering between all VPCs
resource "digitalocean_vpc_peering" "peering" {
  for_each = {
    for i, region1 in var.regions : "${region1}-${var.regions[i + 1]}" => {
      vpc1 = digitalocean_vpc.vpc[region1].id
      vpc2 = digitalocean_vpc.vpc[var.regions[i + 1]].id
    } if i < length(var.regions) - 1
  }
  vpc_ids = [each.value.vpc1, each.value.vpc2]
  name    = "peering-${each.key}"
}

# create a firewall to allow traffic
resource "digitalocean_firewall" "firewall" {
  name = var.firewall_name
  droplet_ids = flatten([
    for key, droplet in digitalocean_droplet.cloud : droplet.id
  ])

  dynamic "inbound_rule" {
    for_each = var.inbound_rules
    content {
      protocol         = inbound_rule.value.protocol
      port_range       = inbound_rule.value.port_range
      source_addresses = inbound_rule.value.source_addresses
    }
  }

  dynamic "outbound_rule" {
    for_each = var.outbound_rules
    content {
      protocol              = outbound_rule.value.protocol
      port_range            = outbound_rule.value.port_range
      destination_addresses = outbound_rule.value.destination_addresses
    }
  }
}


# create a monitoring alert for each droplet


resource "digitalocean_monitor_alert" "alerts" {
  for_each = { for alert in var.alert_configs : alert.name => alert }

  alerts {
    email = [var.email]
    slack {
      channel = "devops"
      url     = var.slack_webhook
    }
  }
  window      = "5m"
  type        = each.value.type
  compare     = "GreaterThan"
  value       = 95
  enabled     = true
  entities    = [for droplet in digitalocean_droplet.cloud : droplet.id]
  description = each.value.description
}


# create a project resource to group all resources
resource "digitalocean_project_resources" "project_resources" {
  project = data.digitalocean_project.existing_project.id
  resources = concat(
    [for droplet in digitalocean_droplet.cloud : droplet.urn],
    [for pg in digitalocean_database_cluster.database : pg.urn],
  )
}
