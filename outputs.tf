output "region" {
  description = "OCI region used for the deployment."
  value       = var.region
}

output "openclaw_instance_ocid" {
  description = "OpenClaw compute instance OCID."
  value       = oci_core_instance.openclaw.id
}

output "openclaw_private_ip" {
  description = "Private IP address of the OpenClaw instance."
  value       = oci_core_instance.openclaw.private_ip
}

output "bastion_ocid" {
  description = "OCI Bastion OCID (when enabled)."
  value       = var.create_bastion ? oci_bastion_bastion.openclaw[0].id : null
}

output "generated_gateway_token" {
  description = "Gateway token actually used by OpenClaw (generated if none provided)."
  value       = local.effective_gateway_key
  sensitive   = true
}

output "next_steps" {
  description = "Post-deploy checklist."
  value = {
    bastion = var.create_bastion ? "Create a Managed SSH session in OCI Bastion and tunnel local 18789 to instance 127.0.0.1:18789." : "Bastion disabled; use your own secure SSH access path."
    podman  = "On the instance, check service with: sudo -u openclaw podman ps"
    logs    = "On the instance, check logs with: sudo -u openclaw podman logs -f openclaw"
  }
}
