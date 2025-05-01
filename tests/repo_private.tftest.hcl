variables {
  repo_name        = "private-repo-test"
  repo_description = "Private repository for testing"
  repo_visibility  = "private"
  repo_auto_init   = true
}

run "create_private_repo" {
  command = apply
}
