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
            format = "{}";
            seperate-outputs = true;
          };

          "custom/weather" = {
            format = "{}°F";
            tooltip = true;
            interval = 3600;
            exec = "wttrbar --fahrenheit";
            return-type = "json";
          };

          "custom/sep" = {
            format = " | ";
          };

          tray = {
            icon-size = 13;
            spacing = 10;
          };

          clock = {
            format = " {:%R   %m/%d/%y} ";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };

          pulseaudio = {
            format = " {icon}{volume} ";
            format-muted = "󰝟 ";
            format-icons = {
              default = " ";
              headphone = "󰋋";
            };
          };

          backlight = {
            format = "󰖨 {percent} ";
          };

          battery = {
            format = "{icon}{capacity} ";
            interval = 10;
            states = {
              critical = 10;
              warning = 30;
              normal = 50;
              high = 80;
              full = 95;
            };
            format-plugged = "{capacity} ";
            format-charging = "󱐋{capacity} ";
            format-icons = [
              " "
              " "
              " "
              " "
              " "
            ];
          };

          network = {
            format-wifi = " {essid} ";
            format-ethernet = "󰈀 {ipaddr} ";
          };

          mpris = {
            format = "{player_icon} {title} - {artist} ({position}/{length}) ";
            format-paused = "{player_icon} {status} ";
            player-icons = {
              default = "▶";
              mpv = "🎵";
              spotifyd = " ";
            };

            status-icons = {
              paused = "⏸";
            };

            ignored-players = [
              "firefox"
              "librewolf"
              "brave"
            ];
          };

          cpu = {
            format = " {usage}% ";
          };

          memory = {
            format = " {percentage}% ";
          };
        };
      };
    };
  };
}
