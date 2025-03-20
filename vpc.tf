# VPC
resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = "main"
  auto_create_subnetworks = false
}
