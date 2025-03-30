resource "kubernetes_deployment" "reader_api" {
  metadata {
    name      = "reader-api"
    namespace = kubernetes_namespace.reader.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "reader-api"
      }
    }
    template {
      metadata {
        labels = {
          app = "reader-api"
        }
      }
      spec {
        # Main application container
        container {
          image = "${var.region}-docker.pkg.dev/${var.project_id}/reader-repository/reader-api:latest"
          name  = "reader-api"
          port {
            container_port = 8080
          }

          # Database environment variables
          env {
            name  = "DB_HOST"
            value = google_sql_database_instance.postgres.private_ip_address
          }

          env {
            name  = "DB_PORT"
            value = "5432"
          }

          env {
            name  = "DB_NAME"
            value = google_sql_database.reader_postgres.name
          }

          env {
            name  = "DB_USER"
            value = google_sql_user.reader_postgres_user.name
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_credentials.metadata[0].name
                key  = "postgres-password"
              }
            }
          }
        }
      }
    }
  }
}

# Add a service to expose API
resource "kubernetes_service" "reader_api" {
  metadata {
    name      = "reader-api"
    namespace = kubernetes_namespace.reader.metadata[0].name
  }

  spec {
    selector = {
      app = "reader-api"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_secret" "postgres_credentials" {
  metadata {
    name      = "postgres-credentials"
    namespace = kubernetes_namespace.reader.metadata[0].name
  }

  data = {
    "postgres-password" = random_password.postgres_password.result
  }

  type = "Opaque"
}
