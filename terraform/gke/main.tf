terraform {
  required_version = ">= 0.11.11"
  backend "gcs" {
    bucket = "puppet-kevins-bucket"
    prefix = "puppet-kevins"

  }
}

provider "google" {
  credentials = "${var.google-credentials}"
  project     = "${local.workspace["gcp_project"]}"
  region      = "${local.workspace["gcp_region"]}"
}

resource "google_container_cluster" "demo" {
  name               = "kevins-cluster"
  description        = "Demo K8S cluster"
  location           = "${local.workspace["gcp_location"]}"
  initial_node_count = "${var.initial_node_count}"

  master_auth {
    username = "${var.master_username}"
    password = "${var.master_password}"

    client_certificate_config {
      issue_client_certificate = true
    }
  }

  node_config {
    machine_type = "${var.node_machine_type}"
    disk_size_gb = "${var.node_disk_size}"
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}