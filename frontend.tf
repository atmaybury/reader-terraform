resource "kubernetes_deployment" "reader_client" {
  metadata {
    name      = "reader-client"
    namespace = kubernetes_namespace.reader.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "reader-client"
      }
    }

    template {
      metadata {
        labels = {
          app = "reader-client"
        }
      }

      spec {
        container {
          image = "${var.region}-docker.pkg.dev/${var.project_id}/reader-repository/reader-client:latest"
          name  = "reader-client"

          port {
            container_port = 80
          }

          env {
            name  = "API_URL"
            value = "http://34.129.57.226"
          }
        }
      }
    }
  }
}

# Add a service to expose API
resource "kubernetes_service" "reader_client" {
  metadata {
    name      = "reader-client"
    namespace = kubernetes_namespace.reader.metadata[0].name
  }

  spec {
    selector = {
      app = "reader-client"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
