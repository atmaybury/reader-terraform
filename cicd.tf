# Create service account for CI/CD
resource "google_service_account" "cicd_service_account" {
  account_id   = "cicd-deployer"
  display_name = "CI/CD Deployment Service Account"
  description  = "Service account used for CI/CD deployments from GitHub Actions"
}

# Grant permissions to push to Artifact Registry
resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cicd_service_account.email}"
}

# Grant permissions to manage GKE deployments
resource "google_project_iam_member" "gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.cicd_service_account.email}"
}

# Create a service account key (will be used by GitHub Actions)
resource "google_service_account_key" "cicd_key" {
  service_account_id = google_service_account.cicd_service_account.name
}

# Export the key for use in CI/CD (sensitive - handle securely)
output "cicd_service_account_key" {
  value       = google_service_account_key.cicd_key.private_key
  sensitive   = true
  description = "Base64 encoded private key for the CI/CD service account"
}
