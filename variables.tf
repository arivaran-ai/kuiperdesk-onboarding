variable "project_id" {
  type        = string
  description = "Existing customer project selected in Cloud Shell/Infrastructure Manager."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a canonical 6-30 character Google Cloud project ID."
  }
}

variable "tenant_id" {
  type        = string
  description = "Immutable KuiperDesk tenant UUID bound into the WIF attribute condition."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "tenant_id must be a UUID."
  }
}

variable "installation_id" {
  type        = string
  description = "One-time KuiperDesk authorization-session UUID used in deterministic resource names."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.installation_id))
    error_message = "installation_id must be a UUID."
  }
}

variable "issuer_uri" {
  type        = string
  description = "Exact HTTPS issuer of the KuiperDesk projected workload assertion."

  validation {
    condition     = startswith(var.issuer_uri, "https://") && length(var.issuer_uri) <= 2048
    error_message = "issuer_uri must be a bounded HTTPS URL."
  }
}

variable "return_url" {
  type        = string
  description = "Short-lived signed KuiperDesk callback URL. It contains no Google credential."

  validation {
    condition     = startswith(var.return_url, "https://") && length(var.return_url) <= 8192
    error_message = "return_url must be a bounded HTTPS URL."
  }
}

variable "deployment_profile" {
  type        = string
  default     = "authorization-only"
  description = "v1 creates only the direct read-back identity and required APIs."

  validation {
    condition     = var.deployment_profile == "authorization-only"
    error_message = "v1 supports only the authorization-only deployment profile."
  }
}
