locals {
  artifact_image = flatten([
  for repo_key, repo_val in var.repository : [
  for art_key, art_val in repo_val.artifacts.image : {
    key              = join(".", [repo_key, art_key])
    repo_key         = repo_key
    art_key          = art_key
    image_name       = art_val.image_name
    spec_output_name = art_val.spec_output_name
  }
  ] if repo_val.artifacts != null
  ])
  artifact_manifest = flatten([
  for repo_key, repo_val in var.repository : [
  for art_key, art_val in repo_val.artifacts.manifest : {
    key              = join(".", [repo_key, art_key])
    repo_key         = repo_key
    art_key          = art_key
    artifact_name    = art_val.manifest_name
    spec_output_name = art_val.spec_output_name
  }
  ] if repo_val.artifacts != null
  ])
  deploy_oke = flatten([
  for repo_key, repo_val in var.repository : [
  for dpl_key, dpl_val in repo_val.deploy_oke : {
    key          = join(".", [repo_key, dpl_key])
    repo_key     = repo_key
    dpl_key      = dpl_key
    manifest_key = dpl_val.manifest_key
  }
  ] if repo_val.deploy_oke != null
  ])
  deploy_oke_bg = flatten([
  for repo_key, repo_val in var.repository : [
    for dpl_key, dpl_val in repo_val.deploy_oke_bg : {
    key             = join(".", [repo_key, dpl_key])
    repo_key        = repo_key
    dpl_key         = dpl_key
    manifest_key    = dpl_val.manifest_key
    ingress_name    = dpl_val.ingress_name
    namespace_blue  = dpl_val.namespace_blue
    namespace_green = dpl_val.namespace_green
  }
  ] if repo_val.deploy_oke_bg != null
  ])
}