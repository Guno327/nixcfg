{
  config,
  lib,
  pkgs,
  ... 
}:
{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = lib.mkDefault "gunnar";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  home.stateVersion = "24.05"; # DO NOT CHANGE

  home.packages = with pkgs; [
    cowsay
    lutris
    nvtopPackages.amd
    powertop
    webcord
    obsidian
    steamcmd
    protonup-ng
  ];

  home.file = {
  };

  home.sessionVariables = {
    EDITOR = "lvim";
  };

  programs.home-manager.enable = true;
}
