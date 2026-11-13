{ pkgs, ... }:

{
  users.users.aqua = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$.JKE.wCy3WyU5aPT$BgJDDJlGARZK3Bu5IJpDTt8/2PQ.X8WLu5L58/gPhicy0uDppNtyUraQrk/QFI1J3V3bJVa/p5IlTKSVL9gmY1";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICq8ju6Hc+YoVJnr7+zN0ne2ydYQHkoDKCJE9K8aYRrX java@ghost"
    ];
  };

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
