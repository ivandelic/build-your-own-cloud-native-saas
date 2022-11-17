terraform {
  experiments = [module_variable_optional_attrs]
}

resource "oci_apigateway_gateway" "apigateway_gateway" {
  compartment_id = var.compartment_ocid
  endpoint_type  = var.api_gateway_endpoint_public ? "PUBLIC" : "PRIVATE"
  subnet_id      = var.subnet_id
  display_name   = format("%s%s", "apigw-", var.name)
}

resource "oci_apigateway_deployment" "apigateway_deployment" {
  for_each = var.api_deployments != null ? var.api_deployments : {}
  compartment_id = var.compartment_ocid
  gateway_id = oci_apigateway_gateway.apigateway_gateway.id
  path_prefix = each.value.prefix
  display_name   = format("%s%s", "apigw-deploy-", each.key)
  specification {
    dynamic "logging_policies" {
      for_each = each.value.log_enabled ? [1] : []
      content {
        access_log {
          is_enabled = true
        }
        execution_log {
          is_enabled = true
        }
      }
    }
    request_policies {
      dynamic "mutual_tls" {
        for_each = each.value.mutual_tls != null ? [1] : []
        content {
          allowed_sans = concat(each.value.mutual_tls.allowed_sans, [oci_certificates_management_certificate.certificate_client.subject[0].common_name])
          is_verified_certificate_required = true
        }
      }
    }
    dynamic "routes" {
      for_each = each.value.http_routes != null ? each.value.http_routes : []
      content {
        backend {
          url = routes.value.url
          type = "HTTP_BACKEND"
          is_ssl_verify_disabled = routes.value.is_ssl_verify_disabled != null ? routes.value.is_ssl_verify_disabled : false
        }
        path = routes.value.path
        methods = routes.value.methods
      }
    }
  }
}