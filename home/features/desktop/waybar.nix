{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.waybar;
in {
  options.features.desktop.waybar.enable = mkEnableOption "waybar config";

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainbar = {
        layer = "top";
        position = "top";
        mod = "dock";
        exclusive = true;
        passthrough = false;
        gtk-layer-shell = true;
        height = 0;

        "hyprland/window" = {
            format = "> {}";
            seperate-outputs = true;
        };
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          on-click = "activate";
          format = " {name} ";
          persistent_workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
          };
        };
        "custom/weather" = {
          format = "{}°F";
          tooltip = true;
          interval = 3600;
          exec = "wttrbar --fahrenheit --location SLC";
          return-type = "json";
        };
        tray = {
          icon-size = 13;
          spacing = 10;
        };
        clock = {
          format = " {:%R   %d/%m}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        pulseaudio = {
          format = "{icon} {volume}";
          format-muted = "󰝟 ";
          format-icons = {
            default = " ";
            headphone = "󰋋";
          };
        };
        backlight = {
          format = "󰖨  {percent}";
        };
        battery = {
          format = "{icon} {capacity}";
          interval = 10;
          states = {
            critical = 10;
            warning = 30;
            normal = 50;
            high = 80;
            full = 95;
          };
          format-plugged = " {capacity}";
          format-charging = "󱐋 {capacity}";
          format-icons = [ " " " " " " " " " " ]; 
        };
        network = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀  {essid}";
        };
      };
    };
    };
  };
}
