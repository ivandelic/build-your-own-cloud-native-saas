resource "oci_identity_dynamic_group" "coderepo_dynamic_group" {
  count          = var.coderepo_dynamic_group_name != null ? 0 : 1
  compartment_id = var.tenancy_ocid
  description    = "Dynamic group for DevOps Code Repository"
  matching_rule  = "All {resource.type = 'devopsrepository', resource.compartment.id = '${var.compartment_ocid}'}"
  name           = format("CoderepoDG-%s", var.devops_project_name)
}

resource "oci_identity_dynamic_group" "build_dynamic_group" {
  count          = var.build_dynamic_group_name != null ? 0 : 1
  compartment_id = var.tenancy_ocid
  description    = "Dynamic group for DevOps Build Pipeline"
  matching_rule  = "All {resource.type = 'devopsbuildpipeline', resource.compartment.id = '${var.compartment_ocid}'}"
  name           = format("BuildDG-%s", var.devops_project_name)
}

resource "oci_identity_dynamic_group" "deploy_dynamic_group" {
  count          = var.deploy_dynamic_group_name != null ? 0 : 1
  compartment_id = var.tenancy_ocid
  description    = "Dynamic group for DevOps Deploy Pipeline"
  matching_rule  = "All {resource.type = 'devopsdeploypipeline', resource.compartment.id = '${var.compartment_ocid}'}"
  name           = format("DeployDG-%s", var.devops_project_name)
}

resource "oci_identity_dynamic_group" "connection_dynamic_group" {
  count          = var.connection_dynamic_group_name != null ? 0 : 1
  compartment_id = var.tenancy_ocid
  description    = "Dynamic group for DevOps Connection"
  matching_rule  = "All {resource.type = 'devopsconnection', resource.compartment.id = '${var.compartment_ocid}'}"
  name           = format("ConnectionDG-%s", var.devops_project_name)
}

resource "oci_identity_policy" "devops_general_policy" {
  count          = var.devops_general_policy_name != null ? 0 : 1
  compartment_id = var.compartment_ocid
  description    = "General policy for DevOps service "
  name           = format("DevOps-%s", var.devops_project_name)
  statements     = [
    "Allow dynamic-group ${var.coderepo_dynamic_group_name == null ? oci_identity_dynamic_group.coderepo_dynamic_group[0].name : var.coderepo_dynamic_group_name} to manage devops-family in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.coderepo_dynamic_group_name == null ? oci_identity_dynamic_group.coderepo_dynamic_group[0].name : var.coderepo_dynamic_group_name} to read secret-family in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to read secret-family in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to manage devops-family in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to manage repos in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to manage generic-artifacts in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to use ons-topics in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to read secret-family in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to manage repos in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to use artifact-repositories in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to manage generic-artifacts in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.build_dynamic_group_name == null ? oci_identity_dynamic_group.build_dynamic_group[0].name : var.build_dynamic_group_name} to manage all-artifacts in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.deploy_dynamic_group_name == null ? oci_identity_dynamic_group.deploy_dynamic_group[0].name : var.deploy_dynamic_group_name} to manage all-resources in compartment ${var.compartment_name}",
    "Allow dynamic-group ${var.connection_dynamic_group_name == null ? oci_identity_dynamic_group.connection_dynamic_group[0].name : var.connection_dynamic_group_name} to read secret-family in compartment ${var.compartment_name}"
  ]
}