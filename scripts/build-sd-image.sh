#!/usr/bin/env bash
# Builds a flashable disk image for a host defined in this flake.
#
# Usage: build-sd-image.sh [--from-source] [host]
#
#   --from-source  Ignore the nixos-raspberrypi binary cache and compile
#                   everything (kernel, firmware, bootloader, ...) locally.
#                   Much slower, especially cross-building aarch64 under
#                   binfmt emulation -- only use this if you don't want to
#                   trust that cache.
#
# Note: Raspberry Pi firmware boots from a raw disk image, not an ISO9660
# filesystem -- there's no optical-media boot path on this hardware. The
# output here just uses a .iso extension for convenience; flash it with
# flash-iso.sh (or dd) exactly like a .img file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

FROM_SOURCE=0
HOST=""
for arg in "$@"; do
  case "$arg" in
    --from-source) FROM_SOURCE=1 ;;
    *) HOST="$arg" ;;
  esac
done
HOST="${HOST:-dashboard-nix-btw}"

OUT_DIR="$PWD"
OUT="$OUT_DIR/$HOST.iso"

NIX_BUILD_ARGS=(--no-link --print-out-paths)
if [[ "$FROM_SOURCE" -eq 1 ]]; then
  echo "Building from source -- ignoring the nixos-raspberrypi binary cache."
  NIX_BUILD_ARGS+=(--no-substitute)
else
  NIX_BUILD_ARGS+=(--accept-flake-config)
fi

echo "Building SD image for $HOST ..."
STORE_PATH="$(nix build "$REPO_ROOT#nixosConfigurations.$HOST.config.system.build.sdImage" \
  "${NIX_BUILD_ARGS[@]}")"

IMAGES=("$STORE_PATH"/sd-image/*)
IMAGE="${IMAGES[0]}"

if [[ "$IMAGE" == *.zst ]]; then
  command -v zstd >/dev/null || {
    echo "zstd not found -- run this inside 'nix-shell -p zstd' (or add it to your shell)." >&2
    exit 1
  }
  echo "Decompressing $(basename "$IMAGE") -> $OUT ..."
  zstd -dc "$IMAGE" > "$OUT"
else
  cp "$IMAGE" "$OUT"
fi
chmod u+w "$OUT"

echo
echo "Done: $OUT"
echo "Flash it with: ./scripts/flash-iso.sh '$OUT' /dev/sdX"
