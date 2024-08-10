variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
}

variable "regions" {
  description = "Regions to create resources in"
  type        = list(string)
  default     = ["blr1", "ams3", "nyc3"]
}

variable "project_name" {
  description = "Name of the DigitalOcean project"
  type        = string
  default     = "My Project"
}



variable "droplet_name_prefix" {
  description = "Prefix for droplet names"
  type        = string
  default     = "cloud"
}

variable "droplet_count" {
  description = "Number of droplets to create"
  type        = number
  default     = 1
}

variable "droplet_image" {
  description = "Droplet image"
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "droplet_size" {
  description = "Droplet size"
  type        = string
  default     = "s-1vcpu-1gb"
}


variable "droplet_tags" {
  description = "Droplet tags"
  type        = list(string)
  default     = ["cloud", "api", "docs"]
}



variable "database_clusters" {
  description = "List of database clusters to create"
  type = list(object({
    name : string
    engine : string
    count : number
    size : string
    version : string

  }))
  default = [
    {
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
}



variable "firewall_name" {
  description = "Name of the firewall"
  type        = string
  default     = "my-firewall"
}

variable "inbound_rules" {
  description = "List of inbound rules"
  type = list(object({
    protocol         = string
    port_range       = string
    source_addresses = list(string)
  }))
  default = [

    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "6379"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "27017"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "5432"
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  ]
}

variable "outbound_rules" {
  description = "List of outbound rules"
  type = list(object({
    protocol              = string
    port_range            = string
    destination_addresses = list(string)
  }))
  default = [
    {
      protocol              = "tcp"
      port_range            = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    }
  ]
}

variable "email" {
  description = "Email address to send alerts to"
  type        = string
  default     = "you@example.com"
}

variable "slack_webhook" {
  description = "Slack webhook URL"
  type        = string
  default     = "https://hooks.slack.com/services/xxxx/xxxx/xxxx"
}

variable "alert_configs" {
  description = "List of alert configurations"
  type = list(object({
    name        = string
    type        = string
    description = string
  }))
  default = [
    {
      name        = "cpu_alert"
      type        = "v1/insights/droplet/cpu"
      description = "Alert about CPU usage"
    },
    {
      name        = "disk_alert"
      type        = "v1/insights/droplet/disk_utilization_percent"
      description = "Alert about Disk usage"
    },
    {
      name        = "memory_alert"
      type        = "v1/insights/droplet/memory_utilization_percent"
      description = "Alert about Memory usage"
    }
  ]
}

