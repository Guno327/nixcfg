{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.ghostty;
in {
  options.features.desktop.ghostty.enable = mkEnableOption "Configure ghostty";

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      bind = [ "$mainMod, RETURN, exec, ghostty -e fish -c 'exec fish'" ];
    };
  };
}
