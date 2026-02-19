# Manual Paths

## Podman-first (recommended on OCI Linux)

The stack uses OpenClaw's upstream Podman bootstrap script by default:

- `setup-podman.sh --quadlet`
- rootless runtime as `openclaw` user
- systemd user service support

Why Podman-first:

- OCI environments commonly standardize on rootless container runtimes.
- OpenClaw maintains first-party Podman bootstrap scripts.

## Docker-compatible path

If your team mandates Docker, OpenClaw can still run with Docker Compose.

Upstream references:

- https://docs.openclaw.ai/install/podman
- https://docs.openclaw.ai/install/gcp
- https://github.com/openclaw/openclaw/blob/main/docker-compose.yml

## OCI GenAI integration modes

### Mode A: Direct API key (fastest)

- Provide `oci_openai_base_url`
- Provide `oci_openai_model_id`
- Provide `oci_genai_api_key`

### Mode B: Vault-backed key (preferred)

- Create secret in OCI Vault containing API key.
- Set `vault_secret_ocid`.
- (Recommended) enable `create_iam_resources=true` or create equivalent policy manually.

Bootstrap attempts vault read via:

```bash
oci secrets secret-bundle get \
  --secret-id <vault-secret-ocid> \
  --auth instance_principal \
  --query 'data."secret-bundle-content".content' \
  --raw-output | base64 -d
```
