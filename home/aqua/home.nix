{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [./aqua.nix ];

  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  programs.zsh.ohMyZsh = {
    enable = true;
    theme = "lukerandall";
    plugins = [ "git" ];
  };
  programs.zsh.interactiveShellInit = ''
    function y() {
      local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
      command yazi "$@" --cwd-file="$tmp"
      IFS= read -r -d ''' cwd < "$tmp"
      [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
      command rm -f -- "$tmp"
    }
  '';
  hjem.users.aqua = {
    user = "aqua";
    directory = "/home/aqua";

    files = {
      ## Neovim
      ".config/nvim".source = ./dotfiles/nvim;
    };
  };
}
