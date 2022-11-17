resource "oci_database_autonomous_database" "autonomous_database_json" {
  lifecycle {
    ignore_changes = [defined_tags]
  }
  compartment_id              = var.compartment_ocid
  db_name                     = upper(replace(var.name, "-", ""))
  display_name                = format("%s%s", "adb-", var.name)
  db_workload                 = "AJD"
  is_dedicated                = false
  db_version                  = "19c"
  cpu_core_count              = 1
  data_storage_size_in_tbs    = 1
  admin_password              = var.adb_admin_password
  license_model               = "LICENSE_INCLUDED"
  is_mtls_connection_required = true
  customer_contacts {
    email = var.adb_customer_contacts_email
  }
  whitelisted_ips = var.whitelisted_ips
}
