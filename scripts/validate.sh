#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

require_cmd terraform
require_cmd yamllint
require_cmd shellcheck
require_cmd awk
require_cmd python3

echo "[1/6] Terraform fmt check"
terraform fmt -check -recursive

echo "[2/6] Terraform init (providers only, no backend)"
terraform init -backend=false -input=false >/tmp/openclaw-terraform-init.log

echo "[3/6] Terraform validate"
terraform validate

echo "[4/6] YAML lint"
yamllint schema.yaml

echo "[5/6] Shell lint"
awk '/content: \|/{flag=1;next}/^runcmd:/{flag=0}flag{sub(/^      /,"");print}' cloud-init.tftpl > /tmp/bootstrap-openclaw-rendered.sh
shellcheck -e SC2016 -x scripts/package-stack.sh /tmp/bootstrap-openclaw-rendered.sh

echo "[6/6] Package smoke test"
./scripts/package-stack.sh /tmp/openclaw-on-oci-stack.zip >/tmp/openclaw-package.log

echo "Validation passed"
