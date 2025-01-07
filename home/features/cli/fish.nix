{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.fish;
in {
  options.features.cli.fish.enable = mkEnableOption "enable extended fish configuration";
  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      loginShellInit = ''
        set -x NIX_PATH nixpkgs=channel:nixos-unstable
        set -x NIX_LOG info
        set -x TERMINAL kitty
      '';
      shellAbbrs = {
        ".." = "cd ..";
        "..." = "cd ../..";
        ps = "procs";
        switch = "sudo nixos-rebuild switch --flake /home/gunnar/.nixcfg#$FLAKE_BRANCH";
        steam = "steam &> /dev/null & disown";
      };
    };
  };
}
