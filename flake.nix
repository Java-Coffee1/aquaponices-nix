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

  outputs = { self, nixpkgs, nixos-raspberrypi, hjem, ... }@inputs: {
    nixosConfigurations.dashboard-nix-btw = nixos-raspberrypi.lib.nixosSystem {
      specialArgs = inputs;
      modules = [
        {
          imports = with nixos-raspberrypi.nixosModules; [
            raspberry-pi-5.base
            raspberry-pi-5.display-vc4
            raspberry-pi-5.bluetooth
            sd-image
          ];
        }
        hjem.nixosModules.default
        ./hosts/dashboard-nix-btw/default.nix
      ];
    };
  };
}
