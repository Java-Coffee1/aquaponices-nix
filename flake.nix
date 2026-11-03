{
  description = "NixOS configuration for the aquaponics dashboard Raspberry Pi";

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