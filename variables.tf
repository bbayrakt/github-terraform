variable "repo_name" {
  description = "The name of the repository."
  type        = string
}

variable "repo_description" {
  description = "A description of the repository."
  type        = string
  default     = ""
}

variable "repo_homepage_url" {
  description = "URL of a page describing the project."
  type        = string
  default     = ""
}

variable "repo_visibility" {
  description = "Can be public, private or internal."
  type        = string
  default     = "public"

  validation {
    error_message = "Can be 'public', 'private', or 'internal'."
    condition     = contains(["public", "private", "internal"], var.repo_visibility)
  }
}

variable "repo_has_issues" {
  description = "Set to true to enable the GitHub Issues features on the repository."
  type        = bool
  default     = false
}

variable "repo_has_discussions" {
  description = "Set to true to enable GitHub Discussions on the repository."
  type        = bool
  default     = false
}

variable "repo_has_projects" {
  description = "Set to true to enable the GitHub Projects features on the repository."
  type        = bool
  default     = false
}

variable "repo_has_wiki" {
  description = "Set to true to enable the GitHub Wiki features on the repository."
  type        = bool
  default     = false
}

variable "repo_is_template" {
  description = "Set to true to tell GitHub that this is a template repository."
  type        = bool
  default     = false
}

variable "repo_allow_merge_commit" {
  description = "Set to false to disable merge commits on the repository."
  type        = bool
  default     = true
}

variable "repo_allow_squash_merge" {
  description = "Set to true to allow squash merges on the repository."
  type        = bool
  default     = true
}

variable "repo_allow_rebase_merge" {
  description = "Set to true to allow rebase merges on the repository."
  type        = bool
  default     = true
}

variable "repo_allow_auto_merge" {
  description = "Set to true to allow auto-merging pull requests."
  type        = bool
  default     = false
}

variable "repo_squash_merge_commit_title" {
  description = "The title of the commit when using squash merging."
  type        = string
  default     = "COMMIT_OR_PR_TITLE"

  validation {
    error_message = "Can be 'PR_TITLE' or 'COMMIT_OR_PR_TITLE'. Applicable only if 'repo_allow_squash_merge' is true."
    condition     = contains(["PR_TITLE", "COMMIT_OR_PR_TITLE"], var.repo_squash_merge_commit_title)
  }
}

variable "repo_squash_merge_commit_message" {
  description = "The message of the commit when using squash merging."
  type        = string
  default     = "COMMIT_MESSAGES"
  validation {
    error_message = "Can be 'PR_BODY', 'COMMIT_MESSAGES', or 'BLANK'. Applicable only if 'repo_allow_squash_merge' is true."
    condition     = contains(["PR_BODY", "COMMIT_MESSAGES", "BLANK"], var.repo_squash_merge_commit_message)
  }
}

variable "repo_merge_commit_title" {
  description = "The title of the commit when using merge commits. Valid combinations: PR_TITLE with PR_BODY or BLANK message, MERGE_MESSAGE with PR_TITLE message."
  type        = string
  default     = "MERGE_MESSAGE"

  validation {
    error_message = "Allowed values are 'MERGE_MESSAGE' or 'PR_TITLE'."
    condition     = contains(["MERGE_MESSAGE", "PR_TITLE"], var.repo_merge_commit_title)
  }
}

variable "repo_merge_commit_message" {
  description = "The message of the commit when using merge commits. Valid combinations: PR_TITLE title with PR_BODY or BLANK message, MERGE_MESSAGE title with PR_TITLE message."
  type        = string
  default     = "PR_TITLE"

  validation {
    error_message = "Allowed values are 'PR_BODY', 'PR_TITLE', or 'BLANK'."
    condition     = contains(["PR_BODY", "PR_TITLE", "BLANK"], var.repo_merge_commit_message)
  }

  validation {
    error_message = "Invalid combination for merge commit title and message. Valid combinations: PR_TITLE title with PR_BODY/BLANK message, MERGE_MESSAGE title with PR_TITLE message."
    condition = (
      (var.repo_merge_commit_title == "PR_TITLE" && contains(["PR_BODY", "BLANK"], var.repo_merge_commit_message)) ||
      (var.repo_merge_commit_title == "MERGE_MESSAGE" && var.repo_merge_commit_message == "PR_TITLE")
    )
  }
}

variable "repo_delete_branch_on_merge" {
  description = "Automatically delete head branches when pull requests are merged."
  type        = bool
  default     = false
}

variable "repo_web_commit_signoff_required" {
  description = "Require contributors to sign off on web-based commits."
  type        = bool
  default     = false
}

variable "repo_has_downloads" {
  description = "Set to true to enable the (deprecated) downloads feature on the repository."
  type        = bool
  default     = false
}

variable "repo_auto_init" {
  description = "Set to true to produce an initial commit in the repository."
  type        = bool
  default     = false
}

variable "repo_gitignore_template" {
  description = "Use the name of the template without the extension. For example, 'Haskell'. https://github.com/github/gitignore"
  type        = string
  default     = ""
}

variable "repo_license_template" {
  description = "Use the name of the template without the extension. For example, 'mit' or 'mpl-2.0'. https://github.com/github/choosealicense.com/tree/gh-pages/_licenses"
  type        = string
  default     = ""
}

variable "repo_archived" {
  description = "Specifies if the repository should be archived."
  type        = bool
  default     = false
}

variable "repo_archive_on_destroy" {
  description = "Set to true to archive the repository instead of deleting on destroy."
  type        = bool
  default     = false
}

variable "repo_vulnerability_alerts" {
  description = "Set to true to enable security alerts for vulnerable dependencies."
  type        = bool
  default     = false
}

variable "repo_ignore_vulnerability_alerts_during_read" {
  description = "Set to true to ignore vulnerability alerts during read."
  type        = bool
  default     = false
}

variable "repo_allow_update_branch" {
  description = "Set to true to allow branch updates."
  type        = bool
  default     = false
}

variable "repo_pages" {
  description = "Configuration for GitHub Pages. Set to null to disable Pages. `source_branch` is the branch to publish from. `source_path` is the folder to publish from (e.g., '/docs', defaults to root directory). `build_type` can be 'legacy' or 'workflow'. `cname` is the custom domain for the Pages site."
  type = object({
    source_branch = optional(string, "")
    source_path   = optional(string, "")       # Defaults to root if empty string
    build_type    = optional(string, "legacy") # Defaults to legacy
    cname         = optional(string, null)     # Optional custom domain
  })
  default = null # Pages are disabled by default
}

variable "repo_security_and_analysis" {
  description = "Security and analysis settings for the repository. Note that for public repositories, advanced_security is automatically enabled and cannot be configured."
  type = object({
    advanced_security = optional(object({
      status = string # Can be "enabled" or "disabled"
    }), null)
    secret_scanning = optional(object({
      status = string # Can be "enabled" or "disabled"
      }), {
      status = "enabled" # Default matches current state
    })
    secret_scanning_push_protection = optional(object({
      status = string # Can be "enabled" or "disabled"
      }), {
      status = "enabled" # Default matches current state
    })
  })
  default = {
    # Default values match what's currently in the state file
    advanced_security = null
    secret_scanning = {
      status = "enabled"
    }
    secret_scanning_push_protection = {
      status = "enabled"
    }
  }

  validation {
    condition = (
      var.repo_security_and_analysis.advanced_security == null ||
      try(contains(["enabled", "disabled"], var.repo_security_and_analysis.advanced_security.status), false)
    )
    error_message = "Advanced security status must be either 'enabled' or 'disabled'."
  }

  validation {
    condition = (
      var.repo_security_and_analysis.secret_scanning == null ||
      try(contains(["enabled", "disabled"], var.repo_security_and_analysis.secret_scanning.status), false)
    )
    error_message = "Secret scanning status must be either 'enabled' or 'disabled'."
  }

  validation {
    condition = (
      var.repo_security_and_analysis.secret_scanning_push_protection == null ||
      try(contains(["enabled", "disabled"], var.repo_security_and_analysis.secret_scanning_push_protection.status), false)
    )
    error_message = "Secret scanning push protection status must be either 'enabled' or 'disabled'."
  }
}

variable "repo_template" {
  description = "Configuration for creating a repository from a template. Set to null to disable template."
  type = object({
    owner                = string
    repository           = string
    include_all_branches = optional(bool, false)
  })
  default = null
}
