resource "oci_devops_project" "devops_project" {
    compartment_id = var.compartment_ocid
    name = var.devops_project_name
    notification_config {
        topic_id = oci_ons_notification_topic.devops_notification_topic.id
    }
}

resource "oci_devops_repository" "devops_repository" {
    for_each = var.repository != null ? var.repository : {}
    name = each.value.name
    project_id = oci_devops_project.devops_project.id
    repository_type = each.value.mirrored != null ? "MIRRORED" : "HOSTED"
    dynamic "mirror_repository_config" {
        for_each = each.value.mirrored != null ? [1] : []
        content {
            connector_id = oci_devops_connection.connection_git[each.key].id
            repository_url = each.value.mirrored.url
            trigger_schedule {
                schedule_type = each.value.mirrored.frequency != null ? "CUSTOM" : "DEFAULT"
                custom_schedule = each.value.mirrored.frequency != null ? each.value.mirrored.frequency : null
            }
        }
    }
}

resource "oci_devops_connection" "connection_git" {
    for_each = {for key, val in var.repository: key => val if val.mirrored != null}
    access_token = each.value.mirrored.pat_ocid
    connection_type = "GITHUB_ACCESS_TOKEN"
    project_id = oci_devops_project.devops_project.id
    display_name = format("%s-%s", each.value.name, "git-connection")
}

resource "oci_devops_build_pipeline" "devops_build_pipeline" {
    for_each = var.repository != null ? var.repository : {}
    project_id = oci_devops_project.devops_project.id
    display_name = format("%s-%s", each.value.name, "build-pipe")
    dynamic "build_pipeline_parameters" {
        for_each = each.value.build_parameters != null ? [1] : []
        content {
            dynamic "items" {
                for_each = each.value.build_parameters
                content {
                    name = items.value.name
                    default_value = items.value.default_value
                    description = items.value.description != null ? items.value.description : ""
                }
            }
        }
    }
}

resource "oci_devops_build_pipeline_stage" "devops_build_pipeline_stage_build" {
    for_each = var.repository != null ? var.repository : {}
    display_name = format("%s-%s", each.value.name, "build")
    description = "Build artifacts and image from the integrated code repository"
    build_pipeline_id = oci_devops_build_pipeline.devops_build_pipeline[each.key].id
    build_pipeline_stage_type = "BUILD"
    build_spec_file = each.value.build_spec_file
    build_pipeline_stage_predecessor_collection {
        items {
            id = oci_devops_build_pipeline.devops_build_pipeline[each.key].id
        }
    }
    build_source_collection {
        items {
            name = "build-source"
            connection_type = "DEVOPS_CODE_REPOSITORY"
            repository_id = oci_devops_repository.devops_repository[each.key].id
            repository_url = oci_devops_repository.devops_repository[each.key].http_url
            branch = var.build_branch_name
        }
    }
    image = "OL7_X86_64_STANDARD_10"
}

resource "oci_devops_build_pipeline_stage" "devops_build_pipeline_stage_deliver" {
    for_each = {for key, val in var.repository: key => val if val.artifacts != null}
    display_name = format("%s-%s", each.value.name, "deliver")
    description = "Deliver artifacts"
    build_pipeline_id = oci_devops_build_pipeline.devops_build_pipeline[each.key].id
    build_pipeline_stage_type = "DELIVER_ARTIFACT"
    build_pipeline_stage_predecessor_collection {
        items {
            id = oci_devops_build_pipeline_stage.devops_build_pipeline_stage_build[each.key].id
        }
    }
    deliver_artifact_collection {
        dynamic "items" {
            for_each = each.value.artifacts != null ? each.value.artifacts.image != null ? each.value.artifacts.image : {} : {}
            content {
                artifact_id = oci_devops_deploy_artifact.devops_deploy_artifact_image[join(".", [each.key, items.key])].id
                artifact_name = items.value.spec_output_name
            }
        }
        dynamic "items" {
            for_each = each.value.artifacts != null ? each.value.artifacts.manifest != null ? each.value.artifacts.manifest : {} : {}
            content {
                artifact_id = oci_devops_deploy_artifact.devops_deploy_artifact_generic[join(".", [each.key, items.key])].id
                artifact_name = items.value.spec_output_name
            }
        }
    }
}

resource "oci_devops_build_pipeline_stage" "devops_build_pipeline_stage_trigger_oke" {
    for_each = length(local.deploy_oke) > 0 ? { for deployment in local.deploy_oke : deployment.key => deployment } : {}
    display_name = format("%s-%s", each.value.dpl_key, "deploy-trigger-oke")
    description = "Trigger deployment pipeline"
    build_pipeline_id = oci_devops_build_pipeline.devops_build_pipeline[each.value.repo_key].id
    build_pipeline_stage_type = "TRIGGER_DEPLOYMENT_PIPELINE"
    is_pass_all_parameters_enabled = true
    deploy_pipeline_id = oci_devops_deploy_pipeline.devops_deploy_pipeline[each.value.repo_key].id
    build_pipeline_stage_predecessor_collection {
        items {
            id = oci_devops_build_pipeline_stage.devops_build_pipeline_stage_deliver[each.value.repo_key].id
        }
    }
}

resource "oci_devops_build_pipeline_stage" "devops_build_pipeline_stage_trigger_oke_bg" {
    for_each = length(local.deploy_oke_bg) > 0 ? { for deployment in local.deploy_oke_bg : deployment.key => deployment } : {}
    display_name = format("%s-%s", each.value.dpl_key, "deploy-trigger-oke-bg")
    description = "Trigger deployment pipeline"
    build_pipeline_id = oci_devops_build_pipeline.devops_build_pipeline[each.value.repo_key].id
    build_pipeline_stage_type = "TRIGGER_DEPLOYMENT_PIPELINE"
    is_pass_all_parameters_enabled = true
    deploy_pipeline_id = oci_devops_deploy_pipeline.devops_deploy_pipeline[each.value.repo_key].id
    build_pipeline_stage_predecessor_collection {
        items {
            id = oci_devops_build_pipeline_stage.devops_build_pipeline_stage_deliver[each.value.repo_key].id
        }
    }
}

resource "oci_devops_deploy_artifact" "devops_deploy_artifact_image" {
    for_each = length(local.artifact_image) > 0 ? { for artifact in local.artifact_image : artifact.key => artifact } : {}
    argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
    deploy_artifact_source {
        deploy_artifact_source_type = "OCIR"
        image_uri = format("%s:$%s", each.value.image_name, "{buildId}")
    }
    deploy_artifact_type = "DOCKER_IMAGE"
    project_id = oci_devops_project.devops_project.id
    display_name = each.key
}

resource "oci_devops_deploy_artifact" "devops_deploy_artifact_generic" {
    for_each = length(local.artifact_manifest) > 0 ? { for artifact in local.artifact_manifest : artifact.key => artifact } : {}
    argument_substitution_mode = "SUBSTITUTE_PLACEHOLDERS"
    deploy_artifact_source {
        deploy_artifact_source_type = "GENERIC_ARTIFACT"
        deploy_artifact_path = each.value.artifact_name
        deploy_artifact_version = format("$%s", "{buildId}")
        repository_id = oci_artifacts_repository.artifacts_repository[0].id
    }
    deploy_artifact_type = "KUBERNETES_MANIFEST"
    project_id = oci_devops_project.devops_project.id
    display_name = each.value.artifact_name
}

resource "oci_devops_trigger" "devops_trigger" {
    for_each = var.repository != null ? var.repository : {}
    actions {
        build_pipeline_id = oci_devops_build_pipeline.devops_build_pipeline[each.key].id
        type = "TRIGGER_BUILD_PIPELINE"
    }
    project_id = oci_devops_project.devops_project.id
    trigger_source = "DEVOPS_CODE_REPOSITORY"
    repository_id = oci_devops_repository.devops_repository[each.key].id
    display_name = format("%s-%s", each.value.name, "trigger-build")
}

resource "oci_devops_deploy_environment" "deploy_environment" {
    for_each = {for key, val in var.repository: key => val if val.deploy_oke != null || val.deploy_oke_bg != null}
    deploy_environment_type = "OKE_CLUSTER"
    project_id = oci_devops_project.devops_project.id
    cluster_id = var.deployment_oke_cluster_ocid
    display_name = "deployment-env-oke"
}

resource "oci_devops_deploy_pipeline" "devops_deploy_pipeline" {
    for_each = {for key, val in var.repository: key => val if val.deploy_oke != null || val.deploy_oke_bg != null}
    project_id = oci_devops_project.devops_project.id
    display_name = format("%s-%s", each.value.name, "deploy-pipe")
    description = "Deploy pipeline2"
    dynamic "deploy_pipeline_parameters" {
        for_each = each.value.deploy_parameters != null ? [1] : []
        content {
            dynamic "items" {
                for_each = each.value.deploy_parameters
                content {
                    name = items.value.name
                    default_value = items.value.default_value
                    description = items.value.description != null ? items.value.description : " "
                }
            }
        }
    }
}

resource "oci_devops_deploy_stage" "devops_deploy_stage_oke" {
    for_each = length(local.deploy_oke) > 0 ? { for deployment in local.deploy_oke : deployment.key => deployment } : {}
    display_name = format("%s-%s", each.value.repo_key, "deploy")
    deploy_pipeline_id = oci_devops_deploy_pipeline.devops_deploy_pipeline[each.value.repo_key].id
    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_pipeline.devops_deploy_pipeline[each.value.repo_key].id
        }
    }
    deploy_stage_type = "OKE_DEPLOYMENT"
    kubernetes_manifest_deploy_artifact_ids = [oci_devops_deploy_artifact.devops_deploy_artifact_generic[join(".", [each.value.repo_key, each.value.manifest_key])].id]
    namespace = var.deployment_oke_cluster_namespace
    oke_cluster_deploy_environment_id = oci_devops_deploy_environment.deploy_environment[each.value.repo_key].id
    rollback_policy {
        policy_type = "AUTOMATED_STAGE_ROLLBACK_POLICY"
    }
}

resource "oci_devops_deploy_stage" "devops_deploy_stage_oke_bg" {
    for_each = length(local.deploy_oke_bg) > 0 ? { for deployment in local.deploy_oke_bg : deployment.key => deployment } : {}
    blue_green_strategy {
        ingress_name = each.value.ingress_name
        namespace_a = each.value.namespace_blue
        namespace_b = each.value.namespace_green
        strategy_type = "NGINX_BLUE_GREEN_STRATEGY"
    }
    display_name = format("%s-%s", each.value.repo_key, "deploy-bg")
    deploy_pipeline_id = oci_devops_deploy_pipeline.devops_deploy_pipeline[each.value.repo_key].id
    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_pipeline.devops_deploy_pipeline[each.value.repo_key].id
        }
    }
    deploy_stage_type = "OKE_BLUE_GREEN_DEPLOYMENT"
    kubernetes_manifest_deploy_artifact_ids = [oci_devops_deploy_artifact.devops_deploy_artifact_generic[join(".", [each.value.repo_key, each.value.manifest_key])].id]
    oke_cluster_deploy_environment_id = oci_devops_deploy_environment.deploy_environment[each.value.repo_key].id
}

output "bg" {
    value = oci_devops_deploy_stage.devops_deploy_stage_oke_bg
}

resource "oci_devops_deploy_stage" "devops_deploy_stage_oke_bg_approve" {
    for_each = length(local.deploy_oke_bg) > 0 ? { for deployment in local.deploy_oke_bg : deployment.key => deployment } : {}
    display_name = format("%s-%s", each.value.repo_key, "approve-bg")
    deploy_pipeline_id = oci_devops_deploy_pipeline.devops_deploy_pipeline[each.value.repo_key].id
    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_stage.devops_deploy_stage_oke_bg[each.key].id
        }
    }
    deploy_stage_type = "MANUAL_APPROVAL"
    approval_policy {
        approval_policy_type = "COUNT_BASED_APPROVAL"
        number_of_approvals_required = 1
    }
}

resource "oci_devops_deploy_stage" "devops_deploy_stage_oke_bg_traffic_shift" {
    for_each = length(local.deploy_oke_bg) > 0 ? { for deployment in local.deploy_oke_bg : deployment.key => deployment } : {}
    display_name = format("%s-%s", each.value.repo_key, "traffic-shift-bg")
    deploy_pipeline_id = oci_devops_deploy_pipeline.devops_deploy_pipeline[each.value.repo_key].id
    deploy_stage_predecessor_collection {
        items {
            id = oci_devops_deploy_stage.devops_deploy_stage_oke_bg_approve[each.key].id
        }
    }
    deploy_stage_type = "OKE_BLUE_GREEN_TRAFFIC_SHIFT"
    oke_blue_green_deploy_stage_id = oci_devops_deploy_stage.devops_deploy_stage_oke_bg[each.key].id
}