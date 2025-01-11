{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.ghostty;
in {
  options.features.desktop.ghostty.enable = mkEnableOption "Configure ghostty";

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        font-family = "FiraCode Nerd Font";
        font-size = 14;
        theme = "Dracula";
      };
    };
    wayland.windowManager.hyprland.settings = {
      bind = [ "$mainMod, RETURN, exec, ghostty -e fish" ];
    };
  };
}
