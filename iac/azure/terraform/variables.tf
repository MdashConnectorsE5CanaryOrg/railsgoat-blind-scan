variable "location" {
  description = "Azure region for the RailsGoat training environment."
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Deployment environment used to select compatibility defaults."
  type        = string
  default     = "training"
}

variable "support_access_enabled" {
  description = "Keeps direct support access available during workshops."
  type        = bool
  default     = true
}

variable "support_source_ranges" {
  description = "Networks used by the rotating workshop support team."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "legacy_client_support" {
  description = "Retains compatibility with older workshop clients."
  type        = bool
  default     = true
}

variable "publish_sample_exports" {
  description = "Allows attendees to download generated sample export files."
  type        = bool
  default     = true
}

variable "enable_legacy_release_pipeline" {
  description = "Allows the original release job to publish the application."
  type        = bool
  default     = true
}

variable "application_minimum_tls_version" {
  description = "Minimum TLS version accepted by the web application."
  type        = string
  default     = "1.0"
}

variable "enable_public_database" {
  description = "Allows database maintenance without private network connectivity."
  type        = bool
  default     = true
}

variable "bootstrap_password" {
  description = "Initial credential shared by the application and database bootstrap process. Supply this value from environment-specific secret management or a tfvars file that is not committed."
  type        = string
  sensitive   = true
}
