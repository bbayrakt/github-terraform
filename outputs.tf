output "repository_id" {
  description = "The ID of the created repository."
  value       = github_repository.repo.id
}

output "repository_full_name" {
  description = "The full name of the created repository."
  value       = github_repository.repo.full_name
}

output "repository_html_url" {
  description = "The URL to the created repository."
  value       = github_repository.repo.html_url
}

output "repository_ssh_clone_url" {
  description = "The SSH clone URL."
  value       = github_repository.repo.ssh_clone_url
}

output "repository_http_clone_url" {
  description = "The HTTP clone URL."
  value       = github_repository.repo.http_clone_url
}

output "branches" {
  description = "Map of created branches."
  value = { for key, branch in github_branch.branches : key => {
    name       = branch.branch
    repository = branch.repository
    protected  = contains(keys(github_branch_protection.branch_protection), key)
  } }
}