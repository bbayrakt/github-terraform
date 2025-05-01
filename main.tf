terraform {
  required_version = ">= 1.11.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.0.0"
    }
  }
}

provider "github" {}

resource "github_repository" "repo" {
  name                                    = var.repo_name
  description                             = var.repo_description
  homepage_url                            = var.repo_homepage_url
  visibility                              = var.repo_visibility
  has_issues                              = var.repo_has_issues
  has_discussions                         = var.repo_has_discussions
  has_projects                            = var.repo_has_projects
  has_wiki                                = var.repo_has_wiki
  is_template                             = var.repo_is_template
  allow_merge_commit                      = var.repo_allow_merge_commit
  allow_squash_merge                      = var.repo_allow_squash_merge
  allow_rebase_merge                      = var.repo_allow_rebase_merge
  allow_auto_merge                        = var.repo_allow_auto_merge
  squash_merge_commit_title               = var.repo_squash_merge_commit_title
  squash_merge_commit_message             = var.repo_squash_merge_commit_message
  merge_commit_title                      = var.repo_merge_commit_title
  merge_commit_message                    = var.repo_merge_commit_message
  delete_branch_on_merge                  = var.repo_delete_branch_on_merge
  web_commit_signoff_required             = var.repo_web_commit_signoff_required
  has_downloads                           = var.repo_has_downloads
  auto_init                               = var.repo_auto_init
  gitignore_template                      = var.repo_gitignore_template != "" ? var.repo_gitignore_template : null
  license_template                        = var.repo_license_template != "" ? var.repo_license_template : null
  archived                                = var.repo_archived
  archive_on_destroy                      = var.repo_archive_on_destroy
  vulnerability_alerts                    = var.repo_vulnerability_alerts
  ignore_vulnerability_alerts_during_read = var.repo_ignore_vulnerability_alerts_during_read
  allow_update_branch                     = var.repo_allow_update_branch

  dynamic "pages" {
    for_each = var.repo_pages != null ? [var.repo_pages] : []
    content {
      dynamic "source" {
        for_each = pages.value.build_type == "workflow" ? [] : [1]
        content {
          branch = pages.value.source_branch
          path   = pages.value.source_path != "" ? pages.value.source_path : null
        }
      }
      build_type = pages.value.build_type
      cname      = pages.value.cname
    }
  }

  dynamic "security_and_analysis" {
    # Only create this block if we have security_and_analysis settings
    for_each = var.repo_security_and_analysis != null ? [var.repo_security_and_analysis] : []

    content {
      # For public repositories, advanced_security is automatically enabled and cannot be explicitly set
      dynamic "advanced_security" {
        for_each = (
          var.repo_visibility != "public" &&
          security_and_analysis.value.advanced_security != null
        ) ? [security_and_analysis.value.advanced_security] : []

        content {
          status = advanced_security.value.status
        }
      }

      dynamic "secret_scanning" {
        for_each = security_and_analysis.value.secret_scanning != null ? [security_and_analysis.value.secret_scanning] : []

        content {
          status = secret_scanning.value.status
        }
      }

      dynamic "secret_scanning_push_protection" {
        for_each = security_and_analysis.value.secret_scanning_push_protection != null ? [security_and_analysis.value.secret_scanning_push_protection] : []

        content {
          status = secret_scanning_push_protection.value.status
        }
      }
    }
  }

  dynamic "template" {
    for_each = var.repo_template != null ? [var.repo_template] : []

    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }
}
