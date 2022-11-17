output "devops_id" {
  value = oci_devops_project.devops_project.id
}

output "artifact_manifest" {
  value = local.artifact_manifest
}

output "devops_repository" {
  value = {
  for key, repo in oci_devops_repository.devops_repository : key => repo.http_url
  }
}