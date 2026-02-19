variable "tenancy_ocid" {
  description = "Tenancy OCID (required for image and IAM data lookups)."
  type        = string
}

variable "region" {
  description = "OCI region where resources are created."
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where OpenClaw network and compute resources are created."
  type        = string
}

variable "availability_domain_number" {
  description = "Availability domain index (1-based) used for the OpenClaw compute instance."
  type        = number
  default     = 1
}

variable "stack_prefix" {
  description = "Resource naming prefix."
  type        = string
  default     = "openclaw"
}

variable "ssh_public_key" {
  description = "SSH public key for opc user access on the OpenClaw instance."
  type        = string
}

variable "image_ocid" {
  description = "Optional custom image OCID. Leave empty to use latest Ubuntu 22.04 image in-region."
  type        = string
  default     = ""
}

variable "instance_shape" {
  description = "Compute shape for OpenClaw instance."
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  description = "OCPUs for Flex shapes."
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Memory in GB for Flex shapes."
  type        = number
  default     = 6
}

variable "boot_volume_size_gbs" {
  description = "Boot volume size in GB."
  type        = number
  default     = 100
}

variable "hostname_label" {
  description = "Hostname label for the private instance VNIC."
  type        = string
  default     = "openclaw"
}

variable "vcn_cidr_block" {
  description = "VCN CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "Public subnet CIDR block (reserved for bastion and future ingress components)."
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr_block" {
  description = "Private subnet CIDR block for OpenClaw compute."
  type        = string
  default     = "10.0.1.0/24"
}

variable "gateway_port" {
  description = "OpenClaw gateway port."
  type        = number
  default     = 18789
}

variable "gateway_bind" {
  description = "OpenClaw gateway bind mode. Use lan when tunneling through SSH/Bastion."
  type        = string
  default     = "lan"
}

variable "openclaw_gateway_token" {
  description = "Optional gateway token. Leave empty to auto-generate a strong random token."
  type        = string
  default     = ""
  sensitive   = true
}

variable "openclaw_repo_url" {
  description = "OpenClaw source repo cloned during bootstrap."
  type        = string
  default     = "https://github.com/openclaw/openclaw.git"
}

variable "acos_repo_url" {
  description = "Optional ACOS skills repo cloned into ~/.openclaw/workspace/acos."
  type        = string
  default     = ""
}

variable "create_bastion" {
  description = "Create OCI Bastion service for private SSH access."
  type        = bool
  default     = true
}

variable "bastion_client_cidr" {
  description = "CIDR allowed to create Bastion sessions (set to your office/home CIDR)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "bastion_max_session_ttl_seconds" {
  description = "Maximum Bastion session TTL in seconds."
  type        = number
  default     = 10800
}

variable "oci_openai_base_url" {
  description = "OCI Generative AI OpenAI-compatible base URL. Optional."
  type        = string
  default     = ""
}

variable "oci_openai_model_id" {
  description = "OCI Generative AI model id for OpenClaw custom provider. Optional."
  type        = string
  default     = ""
}

variable "oci_genai_api_key" {
  description = "OCI Generative AI API key used when vault_secret_ocid is not provided."
  type        = string
  default     = ""
  sensitive   = true
}

variable "vault_secret_ocid" {
  description = "Optional existing Vault Secret OCID containing OCI GenAI API key; fetched at boot via instance principal."
  type        = string
  default     = ""
}

variable "create_iam_resources" {
  description = "Create Dynamic Group + IAM Policy for instance principal access to Generative AI and Vault secret bundles."
  type        = bool
  default     = false
}

variable "dynamic_group_name" {
  description = "Dynamic Group name used for OpenClaw instances (tenancy-wide unique)."
  type        = string
  default     = "openclaw-instances"
}

variable "policy_name" {
  description = "IAM policy name for OpenClaw instance principal permissions."
  type        = string
  default     = "openclaw-policy"
}
