terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
  experiments = [module_variable_optional_attrs]
}