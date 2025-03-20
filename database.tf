# Postgres instance
resource "google_sql_database_instance" "postgres" {
  name                = "postgres"
  database_version    = "POSTGRES_15"
  region              = var.region
  deletion_protection = false
  settings {
    ip_configuration {
      ipv4_enabled = true
    }

    tier = "db-f1-micro"
  }
}

# Main postgres database
resource "google_sql_database" "reader_postgres" {
  name     = "reader-postgres"
  instance = google_sql_database_instance.postgres.name
}

# Generate a random password
resource "random_password" "postgres_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Output the password securely
output "postgres_password" {
  value     = random_password.postgres_password.result
  sensitive = true
}

# User for access to the db
resource "google_sql_user" "reader_postgres_user" {
  name        = "user"
  password_wo = random_password.postgres_password.result
  instance    = google_sql_database_instance.postgres.name
}

# Create the service account
resource "google_service_account" "postgres_proxy" {
  account_id   = "reader-postgres-proxy"
  display_name = "Reader PostgreSQL Proxy Access"
  project      = var.project_id
}

# Grant SQL admin to postgres_proxy service account
resource "google_project_iam_member" "postgres_proxy_role" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.postgres_proxy.email}"
}

# Add account key for postgres_proxy_service_account
resource "google_service_account_key" "postgres_proxy_key" {
  service_account_id = google_service_account.postgres_proxy.name
}

# Output the private key for postgres_proxy service account
output "postgres_proxy_key" {
  description = "Base64-encoded private key for the PostgreSQL proxy service account"
  value       = google_service_account_key.postgres_proxy_key.private_key
  sensitive   = true
}



