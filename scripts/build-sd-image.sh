#!/usr/bin/env bash
# Builds a flashable SD card image for a host defined in this flake.
#
# Raspberry Pi boots from an SD card image (.img), not an ISO — there's no
# optical-media install path on the Pi, so this is the equivalent of "make
# me an installer" for this hardware.
set -euo pipefail

HOST="${1:-dashboard-nix-btw}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$REPO_ROOT"

echo "Building SD image for nixosConfigurations.${HOST} ..."
nix build --accept-flake-config -L \
  ".#nixosConfigurations.${HOST}.config.system.build.sdImage"

IMAGE="$(find result/sd-image -maxdepth 1 -name '*.img*' -print -quit)"

if [[ -z "$IMAGE" ]]; then
  echo "Build finished but no image was found under result/sd-image/" >&2
  exit 1
fi

echo
echo "Image built: $IMAGE"
echo
echo "Flash it to an SD card (replace /dev/sdX with your SD card device):"
echo "  zstd -dc '$IMAGE' | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync"
echo
echo "Double-check /dev/sdX with 'lsblk' first — dd will silently overwrite the wrong disk."
