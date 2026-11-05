{
  description = "NixOS configuration for the aquaponics dashboard Raspberry Pi";

  # nixos-raspberrypi publishes prebuilt kernel/firmware/bootloader derivations
  # here. A flake's nixConfig only applies when that flake is the one being
  # built directly, not from a dependency, so it has to be repeated here too
  # -- otherwise everything gets compiled from source (very slow when
  # cross-building aarch64 under binfmt emulation).
  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixos-raspberrypi,
      hjem,
      ...
    }@inputs:
    let
      mkHost =
        {
          name,
          modules ? [ ],
        }:
        nixos-raspberrypi.lib.nixosSystem {
          specialArgs = inputs;
          modules = [
            ./hosts/${name}
            hjem.nixosModules.default
            { networking.hostName = name; }
          ]
          ++ modules;
        };
    in
    {
      nixosConfigurations = {
        dashboard-nix-btw = mkHost {
          name = "dashboard-nix-btw";
          modules = with nixos-raspberrypi.nixosModules; [
            raspberry-pi-5.base
            raspberry-pi-5.display-vc4
            raspberry-pi-5.bluetooth
            sd-image
          ];
        };
      };
    };
}