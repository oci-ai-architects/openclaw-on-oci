# openclaw-on-oci

Deploy OpenClaw on OCI with a Podman-first runtime, private networking, OCI Bastion access, and optional OCI GenAI integration.

## Deploy Button

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oci-ai-architects/openclaw-on-oci/releases/download/v0.2.1/openclaw-on-oci-stack-v0.2.1.zip)

`Deploy to Oracle Cloud` uses OCI Resource Manager with the Terraform stack in this repository.

## What This Stack Creates

- VCN (`10.0.0.0/16` by default)
- Public subnet (`10.0.0.0/24`)
- Private subnet (`10.0.1.0/24`)
- Internet + NAT gateways
- Private Ubuntu 22.04 compute instance for OpenClaw
- Optional OCI Bastion service for managed SSH
- Optional Dynamic Group + IAM policy for instance principal permissions

## Runtime Model

- Podman-first bootstrap on OCI VM (default)
- OpenClaw installed from upstream repo using `setup-podman.sh --quadlet`
- OpenClaw config and state under `/home/openclaw/.openclaw`
- Optional ACOS skills clone into `/home/openclaw/.openclaw/workspace/acos`

## OCI GenAI Integration

This stack supports OpenClaw custom provider wiring for OCI's OpenAI-compatible endpoint.

You can pass:

- `oci_openai_base_url`
- `oci_openai_model_id`
- `oci_genai_api_key` (or `vault_secret_ocid`)

If `vault_secret_ocid` is set, bootstrap attempts an instance-principal Vault read at first boot.

## Quick Start

1. Click the deploy button.
2. Provide required variables (`compartment_ocid`, `ssh_public_key`, CIDRs).
3. Optionally set OCI GenAI fields.
4. Apply stack and wait for cloud-init completion.
5. Access via Bastion-managed SSH and tunnel local port `18789`.

Detailed guide:

- `docs/quickstart.md`

## Repository Layout

- `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `versions.tf`: OCI stack
- `cloud-init.tftpl`: VM bootstrap
- `schema.yaml`: OCI Resource Manager form schema
- `docs/`: runbooks and setup guides
- `scripts/package-stack.sh`: zip stack for release distribution
- `scripts/validate.sh`: local validation (terraform + lint + package smoke test)

## Validation

Run:

```bash
./scripts/validate.sh
```

## Notes

- For client-facing one-click use, ensure this repository (or the zip URL target) is publicly accessible to OCI Resource Manager.
- If you need strict least-privilege IAM, review and customize policy statements before production rollout.
