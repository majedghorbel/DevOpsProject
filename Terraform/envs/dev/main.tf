module "compute" {
  source      = "../../modules/compute"
  flavor_name = "b2-7"
  region      = "GRA"
}

module "kubernetes" {
  source      = "../../modules/kubernetes"
}

module "registry" {
  source      = "../../modules/registry"
}