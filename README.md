# aquaponices-nix

this is houw I made a iso for the rasberry pi
```
nix build .#nixosConfigurations.dashboard-nix-btw.config.system.build.sdImage
```
ran this command to make the immage on my server would suggest using tmux

will also nee this enable as well 
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

sudo systemctl restart systemd-binfmt

ls /proc/sys/fs/binfmt_misc/