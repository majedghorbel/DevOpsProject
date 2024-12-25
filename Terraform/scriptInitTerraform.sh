#!/bin/bash

# Function to create a file with content
create_file() {
  local filepath=$1
  local content=$2
  echo -e "$content" > "$filepath"
}

echo "Setting up Terraform project for OVHCloud Kubernetes cluster..."

# Define base directories
BASE_DIR="terraform-ovh-k8s"
ENV_DIR="$BASE_DIR/envs"
MODULES_DIR="$BASE_DIR/modules"
SHARED_DIR="$BASE_DIR/shared"

# Create folder structure
mkdir -p "$ENV_DIR/dev" "$ENV_DIR/prod" \
         "$MODULES_DIR/compute" "$MODULES_DIR/network" \
         "$SHARED_DIR"

echo "Directories created."

# Shared providers configuration
create_file "$SHARED_DIR/providers.tf" \
'provider "ovh" {
  endpoint           = "ovh-eu" # Change as per your region
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}'

create_file "$SHARED_DIR/backend.tf" \
'terraform {
  backend "local" { # Change to "s3" or another remote backend if needed
    path = "terraform.tfstate"
  }
}'

create_file "$SHARED_DIR/global-vars.tf" \
'variable "ovh_application_key" {}
variable "ovh_application_secret" {}
variable "ovh_consumer_key" {}'

# Compute module
create_file "$MODULES_DIR/compute/main.tf" \
'resource "ovh_cloud_project_instance" "k8s_instance" {
  count = var.node_count

  name      = "${var.cluster_name}-${count.index == 0 ? "master" : "worker"}-${count.index}"
  flavor_id = count.index == 0 ? var.master_flavor : var.worker_flavor
  image_id  = var.image_id
  region    = var.region

  monthly_billing = true

  ssh_key {
    name = var.ssh_key
  }
}'

create_file "$MODULES_DIR/compute/variables.tf" \
'variable "node_count" { default = 3 }
variable "cluster_name" {}
variable "master_flavor" {}
variable "worker_flavor" {}
variable "image_id" {}
variable "region" {}
variable "ssh_key" {}'

create_file "$MODULES_DIR/compute/outputs.tf" \
'output "instance_ips" {
  value = [for instance in ovh_cloud_project_instance.k8s_instance : instance.ip_addresses[0].ip]
}'

# Network module
create_file "$MODULES_DIR/network/main.tf" \
'resource "ovh_cloud_project_network_private" "k8s_network" {
  name   = var.network_name
  region = var.region
}'

create_file "$MODULES_DIR/network/variables.tf" \
'variable "network_name" {}
variable "region" {}'

create_file "$MODULES_DIR/network/outputs.tf" \
'output "network_id" {
  value = ovh_cloud_project_network_private.k8s_network.id
}'

# Environment configurations (e.g., dev and prod)
for ENV in dev prod; do
  ENV_DIR_PATH="$ENV_DIR/$ENV"

  create_file "$ENV_DIR_PATH/main.tf" \
'module "compute" {
  source         = "../../modules/compute"
  cluster_name   = "k8s-cluster-'$ENV'"
  master_flavor  = "b2-7"
  worker_flavor  = "b2-7"
  image_id       = "Ubuntu_22.04"
  region         = "GRA"
  ssh_key        = "my-ssh-key"
  node_count     = 3
}

module "network" {
  source       = "../../modules/network"
  network_name = "k8s-network-'$ENV'"
  region       = "GRA"
}'

  create_file "$ENV_DIR_PATH/variables.tf" \
'variable "ovh_application_key" {}
variable "ovh_application_secret" {}
variable "ovh_consumer_key" {}'

  create_file "$ENV_DIR_PATH/terraform.tfvars" \
'ovh_application_key    = "your-application-key"
ovh_application_secret = "your-application-secret"
ovh_consumer_key       = "your-consumer-key"'

  create_file "$ENV_DIR_PATH/outputs.tf" \
'output "master_node_ip" {
  value = module.compute.instance_ips[0]
}

output "worker_node_ips" {
  value = [module.compute.instance_ips[1], module.compute.instance_ips[2]]
}'

done

# Gitignore
create_file "$BASE_DIR/.gitignore" \
'.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfvars'

echo "Terraform project structure and files created successfully."

