{
  config,
  lib,
  ...
}: {
  home = {
    username = lib.mkDefault "gunnar.hovik@canonical.com";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    stateVersion = "24.05"; # DO NOT CHANGE
    targets.genericLinux.enable = true;

    sessionVariables = {
      EDITOR = "nix run github:guno327/nvf-flake";
    };
  };

  stylix.targets.hyprlock.enable = false;
  programs.home-manager.enable = true;
}
