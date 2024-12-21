{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprlock;
in {
  options.features.desktop.hyprlock.enable =
    mkEnableOption "Configure hyprlock";

  config = mkIf cfg.enable {
  };
}
