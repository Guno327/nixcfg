{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  home = {
    username = lib.mkDefault "gunnar";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    stateVersion = "24.05"; # DO NOT CHANGE

    packages = with pkgs; [
      cowsay
      steamcmd
    ];

    sessionVariables = {
      EDITOR = "nix run github:guno327/nvf-flake";
    };
  };

  stylix.targets.hyprlock.enable = false;

  programs.home-manager.enable = true;
}
