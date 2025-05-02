resource "github_actions_variable" "vars" {
  for_each = var.actions_variables

  repository = github_repository.repo.name
  variable_name = each.value.variable_name
  value         = each.value.value
}

resource "github_actions_environment_variable" "envvars" {
  for_each = var.actions_environment_variables

  repository = github_repository.repo.name
  environment = each.value.environment
  variable_name = each.value.variable_name
  value         = each.value.value

  depends_on = [ github_repository_environment.envs ]
}

resource "github_actions_repository_access_level" "repo_access" {
  # Access policy only applies to private and internal repositories
  count = var.repo_visibility == "private" || var.repo_visibility == "internal" ? 1 : 0
  
  repository = github_repository.repo.name
  access_level = var.actions_access_level
}
