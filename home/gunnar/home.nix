{ config, lib, pkgs, ... }: {
  home.username = lib.mkDefault "gunnar";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  home.stateVersion = "24.05"; # DO NOT CHANGE

  home.packages = with pkgs; [
    cowsay
    nvtopPackages.amd
    powertop
    steamcmd
  ];

  home.file = {
  };

  home.sessionVariables = {
    EDITOR = "lvim";
  };

  programs.home-manager.enable = true;
}
