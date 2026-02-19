# Quickstart: OpenClaw on OCI

## 1. Prerequisites

- OCI tenancy with permissions for Compute, VCN, and (optional) Bastion/IAM.
- SSH public key.
- OCI GenAI endpoint + API key (if you want OCI as your default model provider).

Official reference for OCI OpenAI-compatible endpoint + key:
- https://docs.oracle.com/en-us/iaas/Content/generative-ai/use-playground-embed.htm

## 2. One-click stack launch

Use the deploy button in `README.md` or open:

`https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oci-ai-architects/openclaw-on-oci/releases/download/v0.2.1/openclaw-on-oci-stack-v0.2.1.zip`

Then set at minimum:

- `compartment_ocid`
- `ssh_public_key`
- `bastion_client_cidr` (set this to your trusted public IP/CIDR)

For OCI GenAI integration, also set:

- `oci_openai_base_url`
- `oci_openai_model_id`
- `oci_genai_api_key` or `vault_secret_ocid`

## 3. Wait for provisioning

The stack creates:

- VCN + public/private subnets
- NAT + Internet gateways
- Private OpenClaw instance (Ubuntu 22.04)
- Optional OCI Bastion
- Optional Dynamic Group + IAM policy

Cloud-init then:

- installs Podman
- clones and bootstraps OpenClaw with `setup-podman.sh --quadlet`
- writes `.env` and `openclaw.json`
- starts/restarts OpenClaw service

## 4. Access the gateway

Recommended: use OCI Bastion managed SSH session, then tunnel gateway locally.

Example tunnel after SSH is established:

```bash
ssh -L 18789:127.0.0.1:18789 opc@<instance-private-ip>
```

Open:

`http://127.0.0.1:18789`

## 5. Validate on the VM

```bash
sudo -u openclaw podman ps
sudo -u openclaw podman logs -f openclaw
sudo -u openclaw cat /home/openclaw/.openclaw/openclaw.json
```
