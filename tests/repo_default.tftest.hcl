variables {
  repo_name        = "test-repo"
  repo_description = "Test repository"
  repo_visibility  = "public"
  repo_auto_init   = true
}

# Test GitHub repository creation with default settings
run "create_repository_with_defaults" {
  command = apply

  assert {
    condition     = github_repository.repo.name == var.repo_name
    error_message = "Repository name did not match expected value."
  }
}

# Test security and analysis settings
run "test_security_and_analysis_configuration" {
  command = apply

  variables {
    repo_security_and_analysis = {
      secret_scanning = {
        status = "enabled"
      }
      secret_scanning_push_protection = {
        status = "enabled"
      }
    }
  }

  assert {
    condition = (
      github_repository.repo.security_and_analysis[0].secret_scanning[0].status == "enabled" &&
      github_repository.repo.security_and_analysis[0].secret_scanning_push_protection[0].status == "enabled"
      )
    error_message = "Security and analysis block should be configured"
  }
}

# Test GitHub Pages configuration
run "test_pages_configuration" {
  command = apply

  variables {
    repo_pages = {
      source_branch = "main"
      source_path = "/docs"
      build_type = "legacy"
      cname = "example.com"
    }
  }

  assert {
    condition     = github_repository.repo.pages[0].build_type == "legacy"
    error_message = "Pages build type should be set to legacy"
  }

  assert {
    condition     = github_repository.repo.pages[0].source[0].branch == "main"
    error_message = "Pages source branch should be set to gh-pages"
  }

  assert {
    condition     = github_repository.repo.pages[0].source[0].path == "/docs"
    error_message = "Pages source path should be set to /docs"
  }
}

# Test GitHub Pages with workflow build type (no source block)
run "test_pages_workflow_build_type" {
  command = apply

  variables {
    repo_pages = {
      build_type = "workflow"
      cname = "workflow.example.com"
    }
  }

  assert {
    condition     = github_repository.repo.pages[0].build_type == "workflow"
    error_message = "Pages build type should be set to workflow"
  }

  assert {
    condition     = github_repository.repo.pages[0].cname == "workflow.example.com"
    error_message = "Pages CNAME should be set to workflow.example.com"
  }
}

run "add_branches" {
  command = apply

  variables {
    repo_branches = {
      development = {
        branch        = "development"
        source_branch = "main"
      },
      staging = {
        branch        = "staging"
        source_branch = "main"
        protection = {
          enabled = true
          rules   = ["require_signed_commits"]
          required_pull_request_reviews = {
            dismiss_stale_reviews = true
            require_code_owner_reviews = true
            required_approving_review_count = 2
          }
        }
      },
      feature = {
        branch        = "feature/new-feature"
        source_branch = "main"
      }
    }
  }

  assert {
    condition     = length(github_branch.branches) == 3
    error_message = "Expected 3 branches to be created"
  }

  assert {
    condition     = github_branch.branches["staging"].branch == "staging"
    error_message = "Staging branch name does not match expected value"
  }

  assert {
    condition     = length(github_branch_protection.branch_protection) == 1
    error_message = "Expected only staging branch to be protected"
  }

  assert {
    condition     = contains(keys(github_branch_protection.branch_protection), "staging")
    error_message = "Expected staging branch to have branch protection enabled"
  }
}
