terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
    }
  }
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = "some_application_key"
  application_secret = "some_application_secret"
  consumer_key       = "some_consumer_key"
}

