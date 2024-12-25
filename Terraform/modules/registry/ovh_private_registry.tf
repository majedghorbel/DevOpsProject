data "ovh_cloud_project_capabilities_containerregistry_filter" "capabilities" {
  service_name = var.service_name
  plan_name    = "SMALL"
  region       = "GRA"
}

resource "ovh_cloud_project_containerregistry" "myregistry" {
  service_name = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.service_name
  plan_id      = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.id
  region       = data.ovh_cloud_project_capabilities_containerregistry_filter.capabilities.region
  name         = "my-devops-private-registry"
}

resource "ovh_cloud_project_containerregistry_user" "myuser" {
    service_name = ovh_cloud_project_containerregistry.myregistry.service_name
    registry_id  = ovh_cloud_project_containerregistry.myregistry.id
    email        = "majed.ghorbel@corp.ovh.com"
    login        = "majed"
}