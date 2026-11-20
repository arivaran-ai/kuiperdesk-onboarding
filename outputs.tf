output "wif_provider_resource_name" {
  description = "Full non-secret provider resource name verified by aaTwinSvc."
  value       = google_iam_workload_identity_pool_provider.arivaran.name
}

output "project_id" {
  description = "Provider-derived customer project ID."
  value       = data.google_project.selected.project_id
}

output "project_number" {
  description = "Provider-derived customer project number bound into the WIF resource name."
  value       = data.google_project.selected.number
}

output "return_to_arivaran" {
  description = "Open after apply. It carries signed state and the URL-encoded, non-secret provider resource name."
  value       = "${var.return_url}&gcp_wif_provider=${urlencode(google_iam_workload_identity_pool_provider.arivaran.name)}"
}

output "delete_behavior" {
  description = "Destroy removes only the pool/provider/direct binding; shared APIs remain enabled."
  value       = "remove-wif-and-project-binding-keep-shared-apis"
}

output "enabled_services" {
  description = "APIs this blueprint enables. They deliberately survive destroy."
  value       = sort(tolist(local.required_services))
}

output "iam_roles_granted" {
  description = "Every IAM role this blueprint grants. v1 grants exactly one, and it is read-only."
  value       = [google_project_iam_member.readback.role]
}

output "estimated_recurring_cost_usd_per_month" {
  description = "Authorization-only v1 creates no billable resource."
  value       = 0
}

output "network_impact" {
  description = "v1 touches no networking resource and opens no ingress."
  value       = "none"
}

output "service_account_keys_created" {
  description = "Always zero. A service-account key is never created or accepted."
  value       = 0
}
