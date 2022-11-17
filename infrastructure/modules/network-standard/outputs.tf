output "vcn_id" {
  value = oci_core_vcn.vcn.id
}
output "subnets" {
  value = oci_core_subnet.subnet
}
output "zone_id" {
  value = oci_dns_zone.zone[0].id
}