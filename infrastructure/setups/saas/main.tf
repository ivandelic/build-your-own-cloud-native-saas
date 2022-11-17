terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.99.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_images" "oke_images" {
  compartment_id = var.compartment_ocid
  display_name   = var.vm_image_name
}

data "oci_identity_compartment" "compartment" {
  id = var.compartment_ocid
}

## ---------------------------------------------------------------------------------------------------------------------
## 1. Virtual Cloud Netowork (VCN)
## ---------------------------------------------------------------------------------------------------------------------
/*
module "vcn" {
  source           = "../../modules/network-standard"
  compartment_ocid = var.compartment_ocid
  dns_zone_name    = var.name
  dns_zone_parent  = var.dns_zone_parent
  dns_zone_enabled = var.dns_zone_enabled
  name             = var.name
  vcn_cidr         = var.vcn_cidr
  vcn_subnets      = var.vcn_subnets
}
*/
## ---------------------------------------------------------------------------------------------------------------------
## 2. Bastion
## ---------------------------------------------------------------------------------------------------------------------
/*
resource "oci_bastion_bastion" "bastion" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = module.vcn.subnets["db-system"].id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  name                         = var.bastion_name
}
*/
## ---------------------------------------------------------------------------------------------------------------------
## 3. Oracle Container Engine for Kubernetes (OKE)
## ---------------------------------------------------------------------------------------------------------------------
/*
module "oke-cluster" {
  source                 = "../../modules/oke-standard"
  compartment_ocid       = var.compartment_ocid
  name                   = var.name
  vcn_id                 = module.vcn.vcn_id
  subnet_id_endpoint     = module.vcn.subnets["endpoint-api"].id
  subnet_id_lb           = module.vcn.subnets["load-balancer"].id
  subnet_id_node         = module.vcn.subnets["worker-node"].id
  k8s_version            = var.k8s_version
  k8s_is_public_endpoint = var.k8s_is_public_endpoint
  pool_name              = var.pool_name
  pool_total_vm          = var.pool_total_vm
  vm_shape               = var.vm_shape
  vm_memory              = var.vm_memory
  vm_ocpu                = var.vm_ocpu
  vm_image_id            = data.oci_core_images.oke_images.images[0].id
  vm_defined_tags        = var.vm_defined_tags
}
*/
## ---------------------------------------------------------------------------------------------------------------------
## 6. Autonomous JSON Database
## ---------------------------------------------------------------------------------------------------------------------
/*
module "adb" {
  source                      = "../../modules/adb-mongo-db"
  compartment_ocid            = var.compartment_ocid
  name                        = var.name
  adb_admin_password          = var.adb_admin_password
  adb_customer_contacts_email = var.adb_customer_contacts_email
  whitelisted_ips = [format("%s;%s", module.vcn.vcn_id, module.vcn.subnets["worker-node"].cidr_block), "0.0.0.0/0"]
}
*/
## ---------------------------------------------------------------------------------------------------------------------
## 7. DevOps
## ---------------------------------------------------------------------------------------------------------------------
/*
module "devops" {
  source                           = "../../modules/devops-oke"
  compartment_ocid                 = var.compartment_ocid
  compartment_name                 = data.oci_identity_compartment.compartment.name
  tenancy_ocid                     = var.tenancy_ocid
  coderepo_dynamic_group_name      = var.coderepo_dynamic_group_name
  build_dynamic_group_name         = var.build_dynamic_group_name
  deploy_dynamic_group_name        = var.deploy_dynamic_group_name
  connection_dynamic_group_name    = var.connection_dynamic_group_name
  devops_general_policy_name       = var.devops_general_policy_name
  devops_notification_topic_name   = var.devops_notification_topic_name
  devops_project_name              = var.devops_project_name
  build_branch_name                = var.build_branch_name
  artifact_repository_name         = var.artifact_repository_name
  deployment_oke_cluster_ocid      = module.oke-cluster.oke_id
  deployment_oke_cluster_namespace = var.deployment_oke_cluster_namespace
  repository                       = var.repository
}
*/
## ---------------------------------------------------------------------------------------------------------------------
## 9. API Gateway
## ---------------------------------------------------------------------------------------------------------------------
/*
module "apigw" {
  source                       = "../../modules/apigw-standard"
  availability_domain          = data.oci_identity_availability_domains.ads.availability_domains[1].name
  compartment_ocid             = var.compartment_ocid
  name                         = var.api_name
  subnet_id                    = module.vcn.subnets["load-balancer"].id
  api_dns_zone_parent          = var.api_dns_zone_parent
  api_deployments              = var.api_deployments
  api_gateway_endpoint_public  = var.api_gateway_endpoint_public
}
*/