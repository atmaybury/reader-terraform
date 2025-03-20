provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "Reader project id"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}
