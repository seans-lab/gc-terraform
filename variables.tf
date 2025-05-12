variable "grafana_cloud_api_key" {
  description = "API key for Grafana Cloud"
  type        = string
  sensitive   = true
}

variable "grafana_cloud_stack_slug" {
  description = "Slug of the Grafana Cloud stack"
  type        = string
}

variable "grafana_cloud_service_account_name" {
  description = "Name of the service account"
  type        = string
  default     = "Terraform Service Account"
}

variable "grafana_cloud_service_account_role" {
  description = "Role of the service account"
  type        = string
  default     = "Admin"
}

variable "grafana_cloud_service_account_token_name" {
  description = "Name of the service account token"
  type        = string
  default     = "terraform serviceaccount key"
}

variable "grafana_cloud_url" {
  description = "URL of the Grafana Cloud stack"
  type        = string
}

variable "grafana_folder_title" {
  description = "Title of the Grafana folder"
  type        = string
  default     = "Terraform NGINX"
}

variable "grafana_folder_uid" {
  description = "UID of the Grafana folder"
  type        = string
  default     = "tf-NGINX"
}

variable "grafana_dashboard_config_file" {
  description = "Path to the dashboard configuration JSON file"
  type        = string
  default     = "dashboard.json"
}

variable "grafana_dashboard_config_file_home" {
  description = "Path to the dashboard configuration JSON file"
  type        = string
  default     = "dashboard.json"
}

variable "service_account_name" {
  description = "Name of the Grafana service account"
  type        = string
  default     = "terraform_test_sa"
}

variable "service_account_role" {
  description = "Role of the Grafana service account"
  type        = string
  default     = "Viewer"
}

variable "role_uid" {
  description = "UID of the Grafana role"
  type        = string
  default     = "restricted"
}

variable "team_id" {
  description = "ID of the Grafana team"
  type        = string
}

variable "dashboard_uid" {
  description = "UID of the Grafana dashboard"
  type        = string
}

variable "dashboard_permission_role" {
  description = "Role for the dashboard permission"
  type        = string
  default     = "Editor"
}

variable "dashboard_permission" {
  description = "Permission for the dashboard"
  type        = string
  default     = "Edit"
}