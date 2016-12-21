# Discover Consul settings
module "consul" {
  source       = "github.com/nubisproject/nubis-terraform//consul?ref=v1.3.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
}

# Configure our Consul provider, module can't do it for us
provider "consul" {
  address    = "${module.consul.address}"
  scheme     = "${module.consul.scheme}"
  datacenter = "${module.consul.datacenter}"
}

# Publish our outputs into Consul for our application to consume
resource "consul_keys" "config" {
  # This one, the application generates, we only read it
  key {
    name = "app_secret_key"
    path = "${module.consul.config_prefix}/APP_SECRET_KEY"
  }

  # The rest, we publish to
  key {
    name   = "db_name"
    path   = "${module.consul.config_prefix}/DB_NAME"
    value  = "${module.database.name}"
    delete = true
  }

  key {
    name   = "db_server"
    path   = "${module.consul.config_prefix}/DB_SERVER"
    value  = "${module.database.address}"
    delete = true
  }

  key {
    name   = "db_username"
    path   = "${module.consul.config_prefix}/DB_USERNAME"
    value  = "${module.database.username}"
    delete = true
  }

  key {
    name   = "db_password"
    path   = "${module.consul.config_prefix}/DB_PASSWORD"
    value  = "${module.database.password}"
    delete = true
  }
}
