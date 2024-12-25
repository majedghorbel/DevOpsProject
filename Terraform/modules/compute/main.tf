resource "openstack_compute_keypair_v2" "ovh_pro_keypair" {
  provider    = openstack.ovh
  name        = "ovh_pro_keypair"
  public_key  = file("~/.ssh/ovh_pro.pub")
}

resource "openstack_compute_instance_v2" "Devops_Instance" {
  name        = "Devops Instance"
  provider    = openstack.ovh
  image_name  = "Ubuntu 20.04"
  flavor_name = var.flavor_name
  region      = var.region
  key_pair    = openstack_compute_keypair_v2.ovh_pro_keypair.name
  user_data   = data.template_file.user_data.rendered
  network {
    name      = "Ext-Net"
  }
}

data "template_file" "user_data" {
  template    = file("/home/majed/Projet_CICD/Terraform/DevOps/templates/envs/dev/user-data-apache.sh")
}

