# general
region           = "eu-frankfurt-1"
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaa..."
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa..."

# user identity
user_ocid        = "ocid1.user.oc1..aaa..."
fingerprint      = "03:4b:..."
private_key_path = "oci_api_key.pem"

name = "byos"

## ---------------------------------------------------------------------------------------------------------------------
## 1. Virtual Cloud Netowork (VCN)
## ---------------------------------------------------------------------------------------------------------------------

vcn_cidr = "10.10.0.0/16"
vcn_subnets = {
  load-balancer = {
    cidr_block = "10.10.10.0/24"
    is_public  = true
    rt_rules = [
      {
        description         = "Traffic from Internet"
        destination         = "0.0.0.0/0"
        destination_type    = "CIDR_BLOCK"
        network_entity_type = "ig"
      }
    ]
    sl_rules = {
      egress_security_rules = [
        {
          destination = "10.10.20.0/24"
          protocol    = "6"
          tcp_options = {
            min = 30000
            max = 32767
          }
        }
      ]
      ingress_security_rules = [
        {
          protocol  = "6"
          source    = "0.0.0.0/0"
          stateless = false
          tcp_options = {
            min = 80
            max = 80
          }
        },
        {
          protocol    = "6"
          source      = "0.0.0.0/0"
          source_type = "CIDR_BLOCK"
          stateless   = false
          tcp_options = {
            max = 443
            min = 443
          }
        }
      ]
    }
  }
  worker-node = {
    cidr_block = "10.10.20.0/24"
    is_public  = false
    rt_rules = [
      {
        description         = "Traffic to Internet"
        destination         = "0.0.0.0/0"
        destination_type    = "CIDR_BLOCK"
        network_entity_type = "ng"
      },
      {
        description         = "traffic to OCI services"
        destination         = "all-fra-services-in-oracle-services-network"
        destination_type    = "SERVICE_CIDR_BLOCK"
        network_entity_type = "sg"
      }
    ]
    sl_rules = {
      egress_security_rules = [
        {
          description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
          destination      = "10.10.20.0/24"
          destination_type = "CIDR_BLOCK"
          protocol         = "all"
        },
        {
          description      = "Path Discovery"
          destination      = "0.0.0.0/0"
          destination_type = "CIDR_BLOCK"
          icmp_options = {
            code = "4"
            type = "3"
          }
          protocol = "1"
        },
        {
          description      = "Allow nodes to communicate with OKE"
          destination      = "all-fra-services-in-oracle-services-network"
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = "6"
        },
        {
          description      = "Access to Kubernetes API Endpoint"
          destination      = "10.10.30.0/24"
          destination_type = "CIDR_BLOCK"
          protocol         = "6"
          tcp_options = {
            min = 6443
            max = 6443
          }
        },
        {
          description      = "Kubernetes worker to control plane communication"
          destination      = "10.10.30.0/24"
          destination_type = "CIDR_BLOCK"
          protocol         = "6"
          tcp_options = {
            min = 12250
            max = 12250
          }
        },
        {
          description      = "Worker Nodes access to Internet"
          destination      = "0.0.0.0/0"
          destination_type = "CIDR_BLOCK"
          protocol         = "6"
        }
      ]
      ingress_security_rules = [
        {
          description = "Allow pods on one worker node to communicate with pods on other worker nodes"
          protocol    = "all"
          source      = "10.10.20.0/24"
        },
        {
          description = "TCP access from Kubernetes Control Plane"
          protocol    = "6"
          source      = "10.10.30.0/24"
        },
        {
          description = "Path discovery"
          icmp_options = {
            code = "4"
            type = "3"
          }
          protocol = "1"
          source   = "0.0.0.0/0"
        },
        {
          description = "Inbound SSH traffic to worker nodes"
          protocol    = "6"
          source      = "0.0.0.0/0"
          tcp_options = {
            min = 22
            max = 22
          }
        },
        {
          description = "Inbound k8s traffic from load balancers"
          protocol    = "6"
          source      = "10.10.10.0/24"
          stateless   = "false"
          tcp_options = {
            min = 30000
            max = 32767
          }
        }
      ]
    }
  }
  endpoint-api = {
    cidr_block = "10.10.30.0/24"
    is_public  = true
    rt_rules = [
      {
        description         = "Traffic to Internet"
        destination         = "0.0.0.0/0"
        destination_type    = "CIDR_BLOCK"
        network_entity_type = "ig"
      }
    ]
    sl_rules = {
      egress_security_rules = [
        {
          description      = "Allow Kubernetes Control Plane to communicate with OKE"
          destination      = "all-fra-services-in-oracle-services-network"
          destination_type = "SERVICE_CIDR_BLOCK"
          protocol         = "6"
          tcp_options = {
            min = 443
            max = 443
          }
        },
        {
          description      = "All traffic to worker nodes"
          destination      = "10.10.20.0/24"
          destination_type = "CIDR_BLOCK"
          protocol         = "6"
        },
        {
          description      = "Path discovery"
          destination      = "10.10.20.0/24"
          destination_type = "CIDR_BLOCK"
          icmp_options = {
            code = "4"
            type = "3"
          }
          protocol = "1"
        }
      ]
      ingress_security_rules = [
        {
          description = "External access to Kubernetes API endpoint"
          protocol    = "6"
          source      = "0.0.0.0/0"
          tcp_options = {
            min = 6443
            max = 6443
          }
        },
        {
          description = "Kubernetes worker to Kubernetes API endpoint communication"
          protocol    = "6"
          source      = "10.10.20.0/24"
          tcp_options = {
            min = 6443
            max = 6443
          }
        },
        {
          description = "Kubernetes worker to control plane communication"
          protocol    = "6"
          source      = "10.10.20.0/24"
          tcp_options = {
            min = 12250
            max = 12250
          }
        },
        {
          description = "Path discovery"
          icmp_options = {
            code = "4"
            type = "3"
          }
          protocol = "1"
          source   = "10.10.20.0/24"
        }
      ]
    }
  }
  db-system = {
    cidr_block = "10.10.40.0/24"
    is_public  = false
    rt_rules = [
      {
        description         = "Traffic to Internet"
        destination         = "0.0.0.0/0"
        destination_type    = "CIDR_BLOCK"
        network_entity_type = "ng"
      },
      {
        description         = "traffic to OCI services"
        destination         = "all-fra-services-in-oracle-services-network"
        destination_type    = "SERVICE_CIDR_BLOCK"
        network_entity_type = "sg"
      }
    ]
    sl_rules = {
      egress_security_rules = [
        {
          description      = "Allows All Egress Traffic"
          destination      = "0.0.0.0/0"
          destination_type = "CIDR_BLOCK"
          protocol         = "6"
        }
      ]
      ingress_security_rules = [
        {
          description = "Allows Path MTU Discovery Fragmentation Messages"
          protocol    = "1"
          source      = "0.0.0.0/0"
          icmp_options = {
            code = "4"
            type = "3"
          }
        },
        {
          description = "Allows SSH Traffic From Anywhere"
          protocol    = "6"
          source      = "0.0.0.0/0"
          tcp_options = {
            min = 22
            max = 22
          }
        },
        {
          description = "Allows SQL*NET Traffic From Within the VCN"
          protocol    = "6"
          source      = "10.10.0.0/16"
          stateless   = "false"
          tcp_options = {
            min = 1521
            max = 1521
          }
        },
        {
          description = "Allows ONS and FAN Traffic From Within the VCN"
          protocol    = "6"
          source      = "10.10.0.0/16"
          stateless   = "false"
          tcp_options = {
            min = 6200
            max = 6200
          }
        }
      ]
    }
  }
}
dns_zone_enabled = true
dns_zone_parent = "ivandelic.com"

## ---------------------------------------------------------------------------------------------------------------------
## 2. Bastion
## ---------------------------------------------------------------------------------------------------------------------

bastion_name = "ByosBastion"

## ---------------------------------------------------------------------------------------------------------------------
## 3. Oracle Container Engine for Kubernetes (OKE)
## ---------------------------------------------------------------------------------------------------------------------

pool_name              = "byos-pool-1"
pool_total_vm          = 3
vm_shape               = "VM.Standard.E4.Flex"
vm_memory              = 16
vm_ocpu                = 2
vm_image_name          = "Oracle-Linux-7.9-2022.10.04-0"
k8s_version            = "v1.24.1"
k8s_is_public_endpoint = true

## ---------------------------------------------------------------------------------------------------------------------
## 6. Autonomous JSON Database
## ---------------------------------------------------------------------------------------------------------------------

adb_admin_password          = ""
adb_customer_contacts_email = ""

## ---------------------------------------------------------------------------------------------------------------------
## 7. DevOps
## ---------------------------------------------------------------------------------------------------------------------

devops_notification_topic_name   = "devops-byos"
devops_project_name              = "byos"
build_branch_name                = "main"
artifact_repository_name         = "byos"
deployment_oke_cluster_namespace = "default"
repository = {
  departments-backend = {
    name = "departments-backend"
    artifacts = {
      image = {
        departments-backend = {
          image_name       = "fra.ocir.io/%REPLACE%/byos/departments-backend"
          spec_output_name = "departments-backend"
        }
      }
      manifest = {
        departments-backend = {
          manifest_name    = "departments-backend-cicd.yaml"
          spec_output_name = "departments_backend_yaml"
        }
      }
    }
    deploy_oke = {
      departments-backend = {
        manifest_key = "departments-backend"
      }
    }
  }
  general-frontend = {
    name = "general-frontend"
    artifacts = {
      image = {
        general-frontend = {
          image_name       = "fra.ocir.io/%REPLACE%/byos/general-frontend"
          spec_output_name = "general-frontend"
        }
      }
      manifest = {
        general-frontend = {
          manifest_name    = "general-frontend-cicd.yaml"
          spec_output_name = "general_frontend_yaml"
        }
      }
    }
    deploy_oke = {
      general-frontend = {
        manifest_key = "general-frontend"
      }
    }
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## 9. API Gateway
## ---------------------------------------------------------------------------------------------------------------------

api_name                    = "byos-api"
api_dns_zone_parent         = "byos.ivandelic.com"
api_gateway_endpoint_public = true
api_deployments = {
  byos-api = {
    prefix      = "/department-api"
    log_enabled = true
    http_routes = [
      {
        url                    = "https://departments.byos.ivandelic.com/department-manager/$${request.path[endpoint]}"
        path                   = "/v1/{endpoint*}"
        methods                = ["GET", "POST", "PUT", "DELETE"]
        is_ssl_verify_disabled = true
      }
    ]
  }
}