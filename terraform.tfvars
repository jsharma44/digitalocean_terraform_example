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


