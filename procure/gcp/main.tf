terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  required_version = ">= 1.5.5"
}

# GCP Configuration
provider "google" {
  credentials = file(var.gcp_credentials_file_path)
  project     = var.project
  region      = var.region
  zone        = var.zone
}
