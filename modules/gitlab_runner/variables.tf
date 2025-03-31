variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "runner_tags" {
  description = "Comma-separated list of tags for the GitLab runner"
  type        = string
  default     = "azure,vm,docker,aks"
}

variable "runner_registration_token" {
  type = string
}

variable "gitlab_url" {
  type = string
}
