#!/usr/bin/env bash
# Builds a flashable disk image for a host defined in this flake, as a .iso
# file.
#
# Note: Raspberry Pi firmware boots from a raw SD card image, not an ISO9660
# filesystem — there's no optical-media boot path on this hardware. This
# script just renames the raw image to a .iso extension; you still flash it
# to an SD card with dd exactly like a .img, it will NOT mount as a CD/DVD.
set -euo pipefail

HOST="${1:-dashboard-nix-btw}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$REPO_ROOT"

echo "Building image for nixosConfigurations.${HOST} ..."
nix build --accept-flake-config -L \
  ".#nixosConfigurations.${HOST}.config.system.build.sdImage"

COMPRESSED="$(find result/sd-image -maxdepth 1 -name '*.img.zst' -print -quit)"

if [[ -z "$COMPRESSED" ]]; then
  echo "Build finished but no image was found under result/sd-image/" >&2
  exit 1
fi

ISO="${REPO_ROOT}/${HOST}.iso"
echo "Decompressing to ${ISO} ..."
zstd -dc "$COMPRESSED" > "$ISO"

echo
echo "Image built: $ISO"
echo
echo "This is still a raw disk image despite the .iso extension — flash it to"
echo "an SD card the same way (replace /dev/sdX with your SD card device):"
echo "  sudo dd if='$ISO' of=/dev/sdX bs=4M status=progress conv=fsync"
echo
echo "Double-check /dev/sdX with 'lsblk' first — dd will silently overwrite the wrong disk."
