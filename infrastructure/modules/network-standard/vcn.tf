terraform {
  experiments = [module_variable_optional_attrs]
}

data "oci_core_services" "services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = format("%s%s", "vcn-", var.name)
  dns_label      = replace(var.name, "-", "")
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = format("%s%s", "ig-", var.name)
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = format("%s%s", "ng-", var.name)
}

resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = format("%s%s", "sg-", var.name)
  services {
    service_id = data.oci_core_services.services.services.0.id
  }
  vcn_id = oci_core_vcn.vcn.id
}

resource "oci_core_local_peering_gateway" "local_peering_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = format("%s%s", "lpg-", var.name)
}

resource "oci_core_subnet" "subnet" {
  for_each = var.vcn_subnets != null ? var.vcn_subnets : {}
  cidr_block                 = each.value.cidr_block
  compartment_id             = var.compartment_ocid
  display_name               = format("%s-%s", "sn", each.key)
  dns_label                  = replace(each.key, "-", "")
  prohibit_public_ip_on_vnic = !each.value.is_public
  route_table_id             = oci_core_route_table.route_table[each.key].id
  security_list_ids          = tolist([for k, v in oci_core_security_list.security_list : v.id if k == each.key])
  vcn_id                     = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "route_table" {
  for_each = var.vcn_subnets != null ? var.vcn_subnets : {}
  compartment_id = var.compartment_ocid
  display_name   = format("%s%s", "rt-", each.key)
  dynamic "route_rules" {
    for_each = each.value.rt_rules != null ? {
    for k, v in each.value.rt_rules : k => v
    if v.network_entity_type == "ig"
    } : {}
    content {
      description       = route_rules.value["description"]
      destination       = route_rules.value["destination"]
      destination_type  = route_rules.value["destination_type"]
      network_entity_id = oci_core_internet_gateway.internet_gateway.id
    }
  }
  dynamic "route_rules" {
    for_each = each.value.rt_rules != null ? {
    for k, v in each.value.rt_rules : k => v
    if v.network_entity_type == "drg"
    } : {}
    content {
      description       = route_rules.value["description"]
      destination       = route_rules.value["destination"]
      destination_type  = route_rules.value["destination_type"]
      network_entity_id = route_rules.value["network_entity_id"]
    }
  }
  dynamic "route_rules" {
    for_each = each.value.rt_rules != null ? {
    for k, v in each.value.rt_rules : k => v
    if v.network_entity_type == "ng"
    } : {}
    content {
      description       = route_rules.value["description"]
      destination       = route_rules.value["destination"]
      destination_type  = route_rules.value["destination_type"]
      network_entity_id = oci_core_nat_gateway.nat_gateway.id
    }
  }
  dynamic "route_rules" {
    for_each = each.value.rt_rules != null ? {
    for k, v in each.value.rt_rules : k => v
    if v.network_entity_type == "sg"
    } : {}
    content {
      description       = route_rules.value["description"]
      destination       = route_rules.value["destination"]
      destination_type  = route_rules.value["destination_type"]
      network_entity_id = oci_core_service_gateway.service_gateway.id
    }
  }
  dynamic "route_rules" {
    for_each = each.value.rt_rules != null ? {
    for k, v in each.value.rt_rules : k => v
    if v.network_entity_type == "lpg"
    } : {}
    content {
      description       = route_rules.value["description"]
      destination       = route_rules.value["destination"]
      destination_type  = route_rules.value["destination_type"]
      network_entity_id = oci_core_local_peering_gateway.local_peering_gateway.id
    }
  }
  vcn_id = oci_core_vcn.vcn.id
}

resource "oci_core_security_list" "security_list" {
  lifecycle {
    ignore_changes = [egress_security_rules, ingress_security_rules]
  }
  for_each = var.vcn_subnets != null ? var.vcn_subnets : {}
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = format("%s%s", "sl-", each.key)
  dynamic "egress_security_rules" {
    for_each = each.value.sl_rules != null ? ( each.value.sl_rules.egress_security_rules != null ? each.value.sl_rules.egress_security_rules : [] ) : []
    content {
      destination      = egress_security_rules.value["destination"]
      protocol         = egress_security_rules.value["protocol"]
      description      = egress_security_rules.value["description"]
      destination_type = egress_security_rules.value["destination_type"]
      stateless        = egress_security_rules.value["stateless"]
      dynamic tcp_options {
        for_each = egress_security_rules.value.tcp_options != null ? [1] : []
        content {
          min = egress_security_rules.value.tcp_options.min
          max = egress_security_rules.value.tcp_options.max
        }
      }
      dynamic udp_options {
        for_each = egress_security_rules.value.udp_options != null ? [1] : []
        content {
          min = egress_security_rules.value.udp_options.min
          max = egress_security_rules.value.udp_options.max
        }
      }
      dynamic icmp_options {
        for_each = egress_security_rules.value.icmp_options != null ? [1] : []
        content {
          type = egress_security_rules.value.icmp_options.type
          code = egress_security_rules.value.icmp_options.code
        }
      }
    }
  }
  dynamic "ingress_security_rules" {
    for_each = each.value.sl_rules != null ? ( each.value.sl_rules.ingress_security_rules != null ? each.value.sl_rules.ingress_security_rules : [] ) : []
    content {
      source      = ingress_security_rules.value["source"]
      protocol    = ingress_security_rules.value["protocol"]
      description = ingress_security_rules.value["description"]
      source_type = ingress_security_rules.value["source_type"]
      stateless   = ingress_security_rules.value["stateless"]
      dynamic tcp_options {
        for_each = ingress_security_rules.value.tcp_options != null ? [1] : []
        content {
          min = ingress_security_rules.value.tcp_options.min
          max = ingress_security_rules.value.tcp_options.max
        }
      }
      dynamic udp_options {
        for_each = ingress_security_rules.value.udp_options != null ? [1] : []
        content {
          min = ingress_security_rules.value.udp_options.min
          max = ingress_security_rules.value.udp_options.max
        }
      }
      dynamic icmp_options {
        for_each = ingress_security_rules.value.icmp_options != null ? [1] : []
        content {
          type = ingress_security_rules.value.icmp_options.type
          code = ingress_security_rules.value.icmp_options.code
        }
      }
    }
  }
}