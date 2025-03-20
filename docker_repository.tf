resource "google_artifact_registry_repository" "reader_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "reader-repository"
  description   = "Main docker repository"
  format        = "DOCKER"
}
