data "google_project" "selected" {
  project_id = var.project_id
}

locals {
  installation_compact = lower(replace(var.installation_id, "-", ""))
  pool_id              = "kd-${substr(local.installation_compact, 0, 20)}"
  provider_id          = "arivaran-${substr(local.installation_compact, 0, 12)}"
  provider_name        = "projects/${data.google_project.selected.number}/locations/global/workloadIdentityPools/${local.pool_id}/providers/${local.provider_id}"

  required_services = toset([
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])
}

resource "google_project_service" "authorization" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "kuiperdesk" {
  project                   = var.project_id
  workload_identity_pool_id = local.pool_id
  display_name              = "KuiperDesk authorization"
  description               = "Tenant and installation-bound KuiperDesk authorization-only v1 pool"
  disabled                  = false

  depends_on = [google_project_service.authorization]
}

resource "google_iam_workload_identity_pool_provider" "arivaran" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.kuiperdesk.workload_identity_pool_id
  workload_identity_pool_provider_id = local.provider_id
  display_name                       = "Arivaran aaTwinSvc"
  description                        = "Exact issuer, audience, tenant, and installation binding; no service-account key"

  attribute_mapping = {
    "google.subject"            = "assertion.sub"
    "attribute.tenant_id"       = "assertion.tenant_id"
    "attribute.installation_id" = "assertion.installation_id"
  }

  # Both halves are load-bearing. The audience already pins the provider, but a
  # provider is long-lived and an installation is one-time: without the second
  # clause an assertion minted for a LATER installation of the same tenant would
  # still satisfy this provider. Google evaluates the condition before it mints
  # a token, so a claim mismatch fails at STS, not at read-back.
  attribute_condition = "assertion.tenant_id == '${var.tenant_id}' && assertion.installation_id == '${var.installation_id}'"

  oidc {
    issuer_uri        = var.issuer_uri
    allowed_audiences = ["//iam.googleapis.com/${local.provider_name}"]
  }

  depends_on = [google_project_service.authorization]
}

resource "google_project_iam_member" "readback" {
  project = var.project_id
  role    = "roles/browser"
  member  = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.kuiperdesk.name}/attribute.tenant_id/${var.tenant_id}"

  depends_on = [google_iam_workload_identity_pool_provider.arivaran]
}
