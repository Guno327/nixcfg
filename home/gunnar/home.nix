{ config, lib, pkgs, ... }: {
  home = {
    username = lib.mkDefault "gunnar";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    stateVersion = "24.05"; # DO NOT CHANGE

    packages = with pkgs; [
      cowsay
      nvtopPackages.amd
      powertop
      steamcmd
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs.home-manager.enable = true;
}
