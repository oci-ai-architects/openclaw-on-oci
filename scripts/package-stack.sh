#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_PATH="${1:-${ROOT_DIR}/dist/openclaw-on-oci-stack.zip}"

mkdir -p "$(dirname "${OUT_PATH}")"

cd "${ROOT_DIR}"

if command -v zip >/dev/null 2>&1; then
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
else
  python3 - <<'PY' "${OUT_PATH}"
import sys
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

out_path = Path(sys.argv[1])
root = Path.cwd()
items = [
    "README.md",
    "cloud-init.tftpl",
    "main.tf",
    "outputs.tf",
    "providers.tf",
    "schema.yaml",
    "variables.tf",
    "versions.tf",
    "docs",
    "scripts",
]

with ZipFile(out_path, "w", compression=ZIP_DEFLATED) as zf:
    for item in items:
        p = root / item
        if p.is_file():
            zf.write(p, p.relative_to(root))
            continue
        for child in p.rglob("*"):
            if child.is_dir():
                continue
            if ".git" in child.parts:
                continue
            zf.write(child, child.relative_to(root))
PY
fi

echo "Created ${OUT_PATH}"
