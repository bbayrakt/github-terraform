variables {
  repo_name        = "branch-test-repo"
  repo_description = "Test repository for branch creation"
  repo_visibility  = "public"
  repo_auto_init   = true
}

# Test creating multiple branches
run "create_multiple_branches" {
  command = apply

  variables {
    repo_branches = {
      development = {
        branch         = "development"
        source_branch  = "main"
      },
      staging = {
        branch         = "staging"
        source_branch  = "main"
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
        branch         = "feature/new-feature"
        source_branch  = "main"
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