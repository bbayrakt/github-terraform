variables {
  repo_name        = "template-test-repo"
  repo_description = "Test repository creation from template"
  repo_visibility  = "public"
  repo_auto_init   = true
}

# Test GitHub repository template
run "test_repository_template" {
  command = apply

  variables {
    repo_template = {
      owner                = "bbayrakt"
      repository           = "template-repo-test"
      include_all_branches = false
    }
  }

  assert {
    condition = (
      github_repository.repo.template[0].owner == "bbayrakt" &&
      github_repository.repo.template[0].repository == "template-repo-test" &&
      github_repository.repo.template[0].include_all_branches == false
    )
    error_message = "Repository template configuration did not match expected values."
  }
}