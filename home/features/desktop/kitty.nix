{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.kitty;
in {
  options.features.desktop.kitty.enable = mkEnableOption "Configure kitty";

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      shellIntegration.enableBashIntegration = true;
      settings = {
        enabled_layouts = "tall:bias=50;full_size=1;mirrored=false";
      };
    };
    programs.fish.shellAbbrs = {
      ssh = "kitten ssh";
    };
    wayland.windowManager.hyprland.settings = {
      bind = ["Super, RETURN, exec, kitty -e fish -c 'exec fish'"];
    };
  };
}
