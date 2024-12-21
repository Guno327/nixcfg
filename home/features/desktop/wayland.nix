{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.wayland;
in {
  options.features.desktop.wayland.enable = mkEnableOption "wayland extra tools and config";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kitty
      hyprshot
      hyprlock
      brave
      dunst
      xdg-desktop-portal
      qt6.qtwayland
      waypipe
      wf-recorder
      wl-mirror
      wl-clipboard
      wlogout
      wtype
      wttrbar
      ydotool
    ];

  };
}
