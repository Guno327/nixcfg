{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.dev;
in {
  options.features.cli.dev.enable = mkEnableOption "enable configuration for devenv";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
    ];

    programs.direnv = {
      enable = true;
    };
  };
}
