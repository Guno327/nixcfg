{
  config,
  lib,
  pkgs,
  ...
}:
{
  home = {
    username = lib.mkDefault "gunnar";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    stateVersion = "24.05"; # DO NOT CHANGE

    packages = with pkgs; [
      cowsay
      steamcmd
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  stylix.targets.hyprlock.enable = false;

  programs.home-manager.enable = true;
}
