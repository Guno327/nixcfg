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
        direnv hook fish | source
      '';
      shellAbbrs = {
        ".." = "cd ..";
        "..." = "cd ../..";
        ps = "procs";
        steam = "steam &> /dev/null & disown";
        dcp = "rsync -r --partial --info=progress2";
      };
    };
  };
}
