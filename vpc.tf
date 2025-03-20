# VPC
resource "google_compute_network" "main" {
  name                    = "main"
  project                 = var.project_id
  auto_create_subnetworks = false
}
