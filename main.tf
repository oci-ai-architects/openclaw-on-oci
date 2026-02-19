data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ubuntu_22" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "random_password" "gateway_token" {
  count   = var.openclaw_gateway_token == "" ? 1 : 0
  length  = 48
  special = false
}

locals {
  vcn_name              = "${var.stack_prefix}-vcn"
  public_subnet_name    = "${var.stack_prefix}-public"
  private_subnet_name   = "${var.stack_prefix}-private"
  instance_name         = "${var.stack_prefix}-gateway"
  bastion_name          = "${var.stack_prefix}-bastion"
  availability_domain   = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_number - 1].name
  selected_image_ocid   = var.image_ocid != "" ? var.image_ocid : data.oci_core_images.ubuntu_22.images[0].id
  effective_gateway_key = var.openclaw_gateway_token != "" ? var.openclaw_gateway_token : random_password.gateway_token[0].result

  policy_statements = compact([
    "Allow dynamic-group ${var.dynamic_group_name} to use generative-ai-family in compartment id ${var.compartment_ocid}",
    var.vault_secret_ocid != "" ? "Allow dynamic-group ${var.dynamic_group_name} to read secret-bundles in compartment id ${var.compartment_ocid}" : null
  ])
}

resource "oci_core_vcn" "openclaw" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr_block]
  display_name   = local.vcn_name
  dns_label      = "oclaw"
}

resource "oci_core_internet_gateway" "openclaw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "${var.stack_prefix}-igw"
  enabled        = true
}

resource "oci_core_nat_gateway" "openclaw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "${var.stack_prefix}-nat"
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "${var.stack_prefix}-public-sl"

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "${var.stack_prefix}-private-sl"

  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr_block

    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "${var.stack_prefix}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.openclaw.id
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openclaw.id
  display_name   = "${var.stack_prefix}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.openclaw.id
  }
}

resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.openclaw.id
  cidr_block                 = var.public_subnet_cidr_block
  display_name               = local.public_subnet_name
  dns_label                  = "pub"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.openclaw.id
  cidr_block                 = var.private_subnet_cidr_block
  display_name               = local.private_subnet_name
  dns_label                  = "priv"
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_instance" "openclaw" {
  availability_domain = local.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = local.instance_name
  shape               = var.instance_shape

  dynamic "shape_config" {
    for_each = length(regexall("Flex", var.instance_shape)) > 0 ? [1] : []
    content {
      ocpus         = var.instance_ocpus
      memory_in_gbs = var.instance_memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    assign_public_ip = false
    hostname_label   = var.hostname_label
    display_name     = "${local.instance_name}-vnic"
  }

  source_details {
    source_type             = "image"
    source_id               = local.selected_image_ocid
    boot_volume_size_in_gbs = var.boot_volume_size_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init.tftpl", {
      openclaw_repo_url     = var.openclaw_repo_url
      acos_repo_url         = var.acos_repo_url
      gateway_token         = local.effective_gateway_key
      gateway_bind          = var.gateway_bind
      gateway_port          = var.gateway_port
      oci_openai_base_url   = var.oci_openai_base_url
      oci_openai_model_id   = var.oci_openai_model_id
      oci_genai_api_key_b64 = base64encode(var.oci_genai_api_key)
      vault_secret_ocid     = var.vault_secret_ocid
    }))
  }
}

resource "oci_bastion_bastion" "openclaw" {
  count = var.create_bastion ? 1 : 0

  compartment_id               = var.compartment_ocid
  bastion_type                 = "STANDARD"
  target_subnet_id             = oci_core_subnet.private.id
  name                         = local.bastion_name
  max_session_ttl_in_seconds   = var.bastion_max_session_ttl_seconds
  client_cidr_block_allow_list = [var.bastion_client_cidr]
}

resource "oci_identity_dynamic_group" "openclaw_instances" {
  count = var.create_iam_resources ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = var.dynamic_group_name
  description    = "Dynamic group for OpenClaw compute instances"
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
}

resource "oci_identity_policy" "openclaw" {
  count = var.create_iam_resources ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = var.policy_name
  description    = "Least-privilege policy for OpenClaw instance principal"
  statements     = local.policy_statements

  depends_on = [oci_identity_dynamic_group.openclaw_instances]
}
