#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_PATH="${1:-${ROOT_DIR}/dist/openclaw-on-oci-stack.zip}"

if ! command -v zip >/dev/null 2>&1; then
  echo "Missing dependency: zip" >&2
  echo "Install it and rerun: sudo apt-get update && sudo apt-get install -y zip" >&2
  exit 1
fi

mkdir -p "$(dirname "${OUT_PATH}")"

cd "${ROOT_DIR}"
zip -r "${OUT_PATH}" \
  README.md \
  cloud-init.tftpl \
  main.tf \
  outputs.tf \
  providers.tf \
  schema.yaml \
  variables.tf \
  versions.tf \
  docs \
  scripts \
  -x "*/.git/*" >/dev/null

echo "Created ${OUT_PATH}"
