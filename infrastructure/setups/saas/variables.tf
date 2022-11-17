# general
variable "region" {
  type = string
}
variable "tenancy_ocid" {
  type = string
}
variable "compartment_ocid" {
  type = string
}

# user identity
variable "user_ocid" {
  type = string
}
variable "fingerprint" {
  type = string
}
variable "private_key_path" {
  type = string
}

variable "name" {
  type = string
}

## ---------------------------------------------------------------------------------------------------------------------
## 1. Virtual Cloud Netowork (VCN)
## ---------------------------------------------------------------------------------------------------------------------

variable "vcn_cidr" {
  type = string
}

variable "vcn_subnets" {
  default = null
  type = map(object({
    cidr_block = string
    is_public  = bool
    rt_rules = list(object({
      description         = string
      destination         = string
      destination_type    = string
      network_entity_type = string
      network_entity_id   = optional(string)
    }))
    sl_rules = object({
      egress_security_rules = optional(list(object({
        destination      = string
        protocol         = string
        description      = optional(string)
        destination_type = optional(string)
        stateless        = optional(bool)
        tcp_options = optional(object({
          min = number
          max = number
        }))
        udp_options = optional(object({
          min = number
          max = number
        }))
        icmp_options = optional(object({
          type = number
          code = optional(number)
        }))
      })))
      ingress_security_rules = optional(list(object({
        source      = string
        protocol    = string
        description = optional(string)
        source_type = optional(string)
        stateless   = optional(bool)
        tcp_options = optional(object({
          min = number
          max = number
        }))
        udp_options = optional(object({
          min = number
          max = number
        }))
        icmp_options = optional(object({
          type = number
          code = optional(number)
        }))
      })))
    })
  }))
}

variable "dns_zone_parent" {
  type = string
}

variable "dns_zone_enabled" {
  type = bool
}

## ---------------------------------------------------------------------------------------------------------------------
## 2. Bastion
## ---------------------------------------------------------------------------------------------------------------------

variable "bastion_name" {
  type = string
}

## ---------------------------------------------------------------------------------------------------------------------
## 3. Oracle Container Engine for Kubernetes (OKE)
## ---------------------------------------------------------------------------------------------------------------------

variable "pool_name" {
  type = string
}

variable "pool_total_vm" {
  type = string
}

variable "vm_shape" {
  type = string
}

variable "vm_memory" {
  type = number
}

variable "vm_ocpu" {
  type = number
}

variable "vm_image_name" {
  type = string
}


variable "vm_defined_tags" {
  type = map
  default = {}
}

variable "k8s_version" {
  type = string
}

variable "k8s_is_public_endpoint" {
  type = bool
}

## ---------------------------------------------------------------------------------------------------------------------
## 6. Autonomous JSON Database
## ---------------------------------------------------------------------------------------------------------------------

variable "adb_admin_password" {
  type = string
}

variable "adb_customer_contacts_email" {
  type = string
}

## ---------------------------------------------------------------------------------------------------------------------
## 7. DevOps
## ---------------------------------------------------------------------------------------------------------------------

variable "coderepo_dynamic_group_name" {
  type    = string
  default = null
}
variable "build_dynamic_group_name" {
  type    = string
  default = null
}
variable "deploy_dynamic_group_name" {
  type    = string
  default = null
}
variable "connection_dynamic_group_name" {
  type    = string
  default = null
}
variable "devops_general_policy_name" {
  type    = string
  default = null
}
variable "devops_notification_topic_name" {
  type = string
}
variable "devops_project_name" {
  type = string
}
variable "repository" {
  type = map(object({
    name     = string
    mirrored = optional(object({
      url       = string
      pat_ocid  = string
      frequency = string
    }))
    artifacts = optional(object({
      image = map(object({
        image_name       = string
        spec_output_name = string
      }))
      manifest = map(object({
        manifest_name    = string
        spec_output_name = string
      }))
    }))
    deploy_oke = optional(map(object({
      manifest_key = string
    })))
    deploy_oke_bg = optional(map(object({
      manifest_key = string
      ingress_name = string
      namespace_blue = string
      namespace_green = string
    })))
  }))
}
variable "build_branch_name" {
  type = string
}
variable "artifact_repository_name" {
  type = string
}
variable "deployment_oke_cluster_namespace" {
  type = string
}

## ---------------------------------------------------------------------------------------------------------------------
## 9. API Gateway
## ---------------------------------------------------------------------------------------------------------------------

variable "api_name" {
  type = string
}
variable "api_dns_zone_parent" {
  type = string
}
variable "api_gateway_endpoint_public" {
  type = bool
}
variable "api_deployments" {
  default = null
  type = map(object({
    prefix      = string
    log_enabled = optional(bool)
    cors = optional(object({
      allowed_origins = list(string)
      allowed_headers = optional(list(string))
      allowed_methods = optional(list(string))
    }))
    mutual_tls = optional(object({
      allowed_sans = optional(list(string))
    }))
    http_routes = list(object({
      url                    = string
      path                   = string
      is_ssl_verify_disabled = optional(bool)
      methods                = list(string)
    }))
  }))
}