# aquaponices-nix

NixOS flake for the aquaponics dashboard, running on a Raspberry Pi 5.

Mainline nixpkgs doesn't support the Pi 5 yet, so this flake builds on the
community [`nixos-raspberrypi`](https://github.com/nvmd/nixos-raspberrypi)
flake (see `flake.nix`) for the kernel, bootloader, and firmware support.

## Building the image

```
./scripts/build-sd-image.sh dashboard-nix-btw
```

(The host name defaults to `dashboard-nix-btw`, so plain `./scripts/build-sd-image.sh` works too.)

This cross-compiles for `aarch64-linux`, which is slow on real Pi hardware
and needs emulation if you're building on an x86_64 box. If you're doing
that, make sure the building machine has:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

then `sudo systemctl restart systemd-binfmt` and check
`ls /proc/sys/fs/binfmt_misc/` for `aarch64`. The build takes a while, so
running it under `tmux` (or similar) is worth it if you're on a remote
server.

The script decompresses the build output and writes `<host>.iso` into the
current directory. (It's a raw disk image, not an ISO9660 filesystem --
Pi firmware doesn't boot from optical media -- the `.iso` name is just a
convention used here.)

## Flashing it (offline install)

Once you have the `.iso` file, no network access is needed to install:

```
./scripts/flash-iso.sh dashboard-nix-btw.iso /dev/sdX
```

Find the right device with `lsblk` first -- the script refuses to target
the disk your system is currently running from, but double-check before
confirming. It asks you to re-type the device path to confirm before it
writes anything.

## First boot

Put the card/drive in the Pi 5 and power it on. Use an Ethernet cable --
there's no Wi-Fi configured in this flake, so it needs a wired connection
to get an address via DHCP.

There's no mDNS/Avahi configured either, so `dashboard-nix-btw.local`
won't resolve. Find its IP from your router's DHCP client list, or plug
in a monitor/keyboard and read it off the console.

```
ssh aqua@<pi-ip>
```

The `aqua` user's SSH key is already baked into the image (see
`home/aqua/aqua.nix`), and password auth / root login are both disabled --
you'll need the private key matching the public key committed there
(`java@ghost`). Swap in your own key before building if that's not one
you hold.

## Making changes after the first install

You don't need to rebuild and reflash an image for every change. Once the
Pi is up over SSH:

```
nixos-rebuild switch --flake .#dashboard-nix-btw --target-host aqua@<pi-ip> --use-remote-sudo
```

run from this repo on your dev machine. Re-flashing is really only for
the first install or a from-scratch recovery.
