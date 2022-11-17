resource "oci_artifacts_repository" "artifacts_repository" {
    count          = length(local.artifact_manifest) > 0 ? 1 : 0
    compartment_id = var.compartment_ocid
    is_immutable = false
    display_name = var.artifact_repository_name
    repository_type = "generic"
}

resource "oci_artifacts_container_repository" "artifacts_container_repository" {
    for_each = length(local.artifact_image) > 0 ? { for artifact in local.artifact_image : artifact.key => artifact } : {}
    compartment_id = var.compartment_ocid
    display_name = format("%s/%s", var.devops_project_name, each.value.repo_key)
    is_immutable = false
    is_public = false
}