{ lib, ... }:

{
  imports = [
    ../../home/aqua/home.nix
    ./networking.nix
    ../../modules/grafana.nix
  ];

  networking.hostName = "dashboard-nix-btw";

  boot.supportedFilesystems.zfs = lib.mkForce false;

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "America/Vancouver";
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
