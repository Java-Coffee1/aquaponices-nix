#!/usr/bin/env bash
# Flashes a raw disk image (e.g. the .iso produced by build-sd-image.sh) to a
# drive with dd. This OVERWRITES THE ENTIRE TARGET DEVICE — there is no undo.
set -euo pipefail

usage() {
  echo "Usage: $0 <image-file> <device>" >&2
  echo "Example: $0 dashboard-nix-btw.iso /dev/sda" >&2
  exit 1
}

[[ $# -eq 2 ]] || usage

IMAGE="$1"
DEVICE="$2"

[[ -f "$IMAGE" ]] || { echo "No such file: $IMAGE" >&2; exit 1; }
[[ -b "$DEVICE" ]] || { echo "Not a block device: $DEVICE" >&2; exit 1; }

# Refuse to touch the disk the running system lives on.
ROOT_DEVICE="$(findmnt -n -o SOURCE / | sed -E 's/p?[0-9]+$//')"
ROOT_DEVICE_RESOLVED="$(readlink -f "$ROOT_DEVICE" 2>/dev/null || echo "$ROOT_DEVICE")"
DEVICE_RESOLVED="$(readlink -f "$DEVICE")"
if [[ "$DEVICE_RESOLVED" == "$ROOT_DEVICE_RESOLVED" ]]; then
  echo "Refusing to flash $DEVICE — that's the disk your system is running from." >&2
  exit 1
fi

echo "Target device:"
lsblk "$DEVICE"
echo
echo "This will PERMANENTLY ERASE everything on $DEVICE and write $IMAGE to it."
read -r -p "Type the device path ($DEVICE) to confirm: " CONFIRM
if [[ "$CONFIRM" != "$DEVICE" ]]; then
  echo "Confirmation did not match, aborting." >&2
  exit 1
fi

# Unmount any mounted partitions of the target device first.
for part in $(lsblk -nrpo NAME "$DEVICE" | tail -n +2); do
  if mountpoint_dev="$(findmnt -n -o TARGET "$part" 2>/dev/null)"; then
    echo "Unmounting $part from $mountpoint_dev"
    sudo umount "$part"
  fi
done

echo "Flashing $IMAGE to $DEVICE ..."
sudo dd if="$IMAGE" of="$DEVICE" bs=4M status=progress conv=fsync
sync

echo
echo "Done. You can remove the drive now."
