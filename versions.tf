terraform {
  # Infrastructure Manager runs Terraform 1.5.7 by default; ">= 1.6" failed tf-init
  # for every customer (#19777, measured on the lab project).
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 7.45.0"
    }
  }
}

provider "google" {
  project = var.project_id
}
