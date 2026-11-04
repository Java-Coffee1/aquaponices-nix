#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-dashboard-nix-btw}"
OUT_DIR="$PWD"

echo "Building SD image for $HOST ..."
STORE_PATH="$(nix build ".#nixosConfigurations.$HOST.config.system.build.sdImage" \
  --no-link --print-out-paths)"

IMAGES=("$STORE_PATH"/sd-image/*)
IMAGE="${IMAGES[0]}"
NAME="$(basename "$IMAGE")"

cp "$IMAGE" "$OUT_DIR/$NAME"
chmod u+w "$OUT_DIR/$NAME"

echo "Done: $OUT_DIR/$NAME"