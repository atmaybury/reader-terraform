# VPC
resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = "main"
  auto_create_subnetworks = true
}

# Required for private access
resource "google_compute_global_address" "private_ip_address" {
  project       = var.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
