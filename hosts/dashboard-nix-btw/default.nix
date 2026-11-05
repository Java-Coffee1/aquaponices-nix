{ lib, ... }:

{
  imports = [
    ../../home/aqua/home.nix
    # ../../modules/grafana.nix disabled until agenix is wired up and the
    # grafana-secret-key.age / grafana-oidc-secret.age files exist under ../../secrets
  ];

  networking.hostName = "dashboard-nix-btw";

  boot.supportedFilesystems.zfs = lib.mkForce false;

  time.timeZone = "Etc/UTC"; # TODO: set to your actual timezone

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.05";
}
