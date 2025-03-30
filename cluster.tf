# Service account
resource "google_service_account" "primary_cluster" {
  project      = var.project_id
  account_id   = "primary-cluster-sa"
  display_name = "Service Account for primary kubernetes cluster"
}

# Permissions for primary_cluster service account
resource "google_project_iam_member" "gke_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.primary_cluster.email}"
}
resource "google_project_iam_member" "monitoring_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.primary_cluster.email}"
}
resource "google_project_iam_member" "logging_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.primary_cluster.email}"
}
resource "google_project_iam_member" "monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.primary_cluster.email}"
}

# Cluster
resource "google_container_cluster" "primary" {
  project  = var.project_id
  name     = "primary"
  location = var.zone
  network  = google_compute_network.main.id

  remove_default_node_pool = true
  initial_node_count       = 1
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# Node pool
resource "google_container_node_pool" "primary" {
  project    = var.project_id
  name       = "primary-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type    = "e2-micro"
    service_account = google_service_account.primary_cluster.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "kubernetes_namespace" "reader" {
  metadata {
    name = "reader-app"
  }
}

