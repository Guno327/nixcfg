{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.foot;
in {
  options.features.desktop.foot.enable = mkEnableOption "Configure foot";

  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          term = "xterm-256color";
        };

        mouse = {
          hide-when-typing = true;
        };
      };
    };
    wayland.windowManager.hyprland.settings = {
      bind = ["$mainMod, RETURN, exec, foot -e fish -c 'exec fish'"];
    };
  };
}
