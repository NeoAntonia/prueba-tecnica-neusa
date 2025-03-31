variable "db_password" {
  type        = string
  sensitive   = true
  description = "The administrator password for the PostgreSQL server"
}
variable "admin_password" {
  type        = string
  sensitive   = true
  description = "The administrator password for the GitLab Runner"
}

variable "runner_registration_token" {
  type = string
}

variable "gitlab_url" {
  type = string
}

variable "rg-name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {}