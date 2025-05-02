variable "actions_variables" {
  description = "A map of GitHub Actions variables to create."
  type = map(object({
    variable_name       = string
    value      = string
  }))
  default     = {}
}

variable "actions_environment_variables" {
  description = "A map of GitHub Actions environment variables to create."
  type = map(object({
    environment       = string
    variable_name     = string
    value      = string
  }))
  default     = {}
}

variable "actions_access_level" {
    description = "The access level for the GitHub Actions repository."
    type = string
    default = "none"
  
    validation {
      condition     = contains(["none", "user", "organization", "enterprise"], var.actions_access_level)
      error_message = "The access level must be one of 'none', 'user', 'organization', or 'enterprise'."
    }
}
