terraform {
  required_version = ">= 0.11.11"
  backend "gcs" {
    bucket = "marc-demo-bucket"
    prefix = "marc-demo"

  }
}

provider "google" {
  credentials = "${var.google-credentials}"
  project     = "${local.workspace["gcp_project"]}"
  region      = "${local.workspace["gcp_region"]}"
}

data "google_client_config" "current" {}

resource "google_container_cluster" "demo" {
  name               = "marcs-cluster"
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

provider "kubernetes" {
  host = "https://${google_container_cluster.demo.endpoint}"
  insecure = true
}

resource "kubernetes_service" "myapp-frontend-svc" {
  metadata {
    name = "myapp-frontend-svc"
    namespace = "default"
    labels = {
      app = "myapp-frontend"
    }
  }
  spec {
    selector = {
      app = "myapp-frontend"
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "LoadBalancer"
  }
}
