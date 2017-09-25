module "worker" {
  source       = "github.com/gozer/nubis-terraform//worker?ref=feature%2Farena"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  ami          = "${var.ami}"
  elb          = "${module.load_balancer.name}"

  # CPU utilisation based autoscaling (with good defaults)
  scale_load_defaults = true

  # Explicitely pick our load limits for up/down scaling


  #scale_up_load = 75


  #scale_down_load = 10

  # Use a custom ssh key
  ssh_key_file = "${var.ssh_key_file}"
  ssh_key_name = "${var.ssh_key_name}"

  # ldap group names
  nubis_sudo_groups = "${var.nubis_sudo_groups}"
  nubis_user_groups = "${var.nubis_user_groups}"
}

module "load_balancer" {
  source       = "github.com/gozer/nubis-terraform//load_balancer?ref=feature%2Farena"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
}

module "database" {
  source                 = "github.com/gozer/nubis-terraform//database?ref=feature%2Farena"
  region                 = "${var.region}"
  environment            = "${var.environment}"
  account                = "${var.account}"
  service_name           = "${var.service_name}"
  client_security_groups = "${module.worker.security_group}"
}

module "dns" {
  source       = "github.com/gozer/nubis-terraform//dns?ref=feature%2Farena"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  target       = "${module.load_balancer.address}"
}
