{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.monitor;
in {
  options.features.cli.monitor.enable = mkEnableOption "enable tools for hw monitoring";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      btop
      glances
      stress
      s-tui
    ];
  };
}
