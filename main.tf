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
        for_each = security_and_analysis.value.secret_scanning != null && var.repo_visibility == "public" ? [security_and_analysis.value.secret_scanning] : []

        content {
          status = secret_scanning.value.status
        }
      }

      dynamic "secret_scanning_push_protection" {
        for_each = security_and_analysis.value.secret_scanning_push_protection != null && var.repo_visibility == "public" ? [security_and_analysis.value.secret_scanning_push_protection] : []

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

resource "github_branch" "branches" {
  for_each = var.repo_branches

  repository    = github_repository.repo.name
  branch        = each.value.branch
  source_branch = each.value.source_branch
  source_sha    = each.value.source_sha
}

# Branch protection for branches with protect_branch=true
resource "github_branch_protection" "branch_protection" {
  for_each = {
    for key, branch in var.repo_branches : key => branch
    if branch.protection != null
  }

  repository_id = github_repository.repo.name
  pattern       = each.value.branch

  enforce_admins                  = try(each.value.protection.enforce_admins, false)
  require_signed_commits          = try(each.value.protection.require_signed_commits, false)
  required_linear_history         = try(each.value.protection.required_linear_history, true)
  require_conversation_resolution = try(each.value.protection.require_conversation_resolution, true)
  force_push_bypassers            = try(each.value.protection.force_push_bypassers, [])
  allows_deletions                = try(each.value.protection.allows_deletions, false)
  allows_force_pushes             = try(each.value.protection.allows_force_pushes, false)
  lock_branch                     = try(each.value.protection.lock_branch, false)

  dynamic "required_status_checks" {
    for_each = try(each.value.protection.required_status_checks, null) != null ? [1] : []
    content {
      strict   = try(each.value.protection.required_status_checks.strict, false)
      contexts = try(each.value.protection.required_status_checks.contexts, [])
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = try(each.value.protection.required_pull_request_reviews, null) != null ? [1] : []
    content {
      dismiss_stale_reviews = try(each.value.protection.required_pull_request_reviews.dismiss_stale_reviews, false)
      restrict_dismissals = try(each.value.protection.required_pull_request_reviews.restrict_dismissals, false)
      dismissal_restrictions = try(each.value.protection.required_pull_request_reviews.dismissal_restrictions, [])
      pull_request_bypassers = try(each.value.protection.required_pull_request_reviews.pull_request_bypassers, [])
      require_code_owner_reviews = try(each.value.protection.required_pull_request_reviews.require_code_owner_reviews, false)
      required_approving_review_count = try(each.value.protection.required_pull_request_reviews.required_approving_review_count, 1)
      require_last_push_approval = try(each.value.protection.required_pull_request_reviews.require_last_push_approval, false)
    }
  }

  dynamic "restrict_pushes" {
    for_each = try(each.value.protection.restrict_pushes, null) != null ? [1] : []
    content {
      blocks_creations = try(each.value.protection.restrict_pushes.blocks_creations, false)
      push_allowances = try(each.value.protection.restrict_pushes.push_allowances, [])
    }
  }

  depends_on = [github_branch.branches]
}
