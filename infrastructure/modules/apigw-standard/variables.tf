# general
variable "compartment_ocid" {
  type = string
}
variable "availability_domain" {
  type = string
}
variable "name" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "api_gateway_endpoint_public" {
  type = bool
}
variable "api_dns_zone_parent" {
  type = string
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
