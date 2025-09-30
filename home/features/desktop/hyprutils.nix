{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprutils;
in {
  options.features.desktop.hyprutils = {
    enable = mkEnableOption "enable config for hyrputils";
    desktop = mkEnableOption "configure for desktop use";
    laptop = mkEnableOption "configure for laptop use";
    lockMonitor = mkOption {
      type = types.str;
      default = "DP-1";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        swaynotificationcenter
        wttrbar
        wleave
        playerctl
      ];

      wayland.windowManager.hyprland.settings = {
        exec-once = [
          "waybar"
          "hyprpaper"
          "swaync"
        ];

        bind = [
          "$mainMod, M, exec, wleave -p layer-shell"
          "$mainMod, D, exec, wofi --show-drun"
          "$mainMod, N, exec, swaync-client -t -sw"
        ];

        bindl = [
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];
      };

      programs.wofi.enable = true;

      services.hyprpaper = {
        enable = true;
        settings = {
          preload = [
            "/flake/home/gunnar/wallpaper.png"
          ];
          wallpaper = [
            ", /flake/home/gunnar/wallpaper.png"
          ];
        };
      };

      programs = {
        waybar = {
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

        hyprlock = {
          enable = true;

          settings = {
            general = {
              disable_loading_bar = true;
              grace = 0;
              hide_cursor = true;
              no_fade_in = false;
              ignore_empty_input = true;
            };
            background = [
              {
                path = "screenshot";
                blur_passes = 3;
                blur_size = 8;
              }
            ];
            input-field = [
              {
                monitor = cfg.lockMonitor;
                size = "200, 50";
                position = "0, -80";
                dots_center = true;
                fade_on_empty = false;
                font_color = "rgb(202, 211, 245)";
                inner_color = "rgb(91, 96, 120)";
                outer_color = "rgb(24, 25, 38)";
                outline_thickness = 5;
                placeholder_text = "Password...";
                shadow_passes = 2;
              }
            ];
            image = [
              {
                monitor = cfg.lockMonitor;
                path = "~/pictures/pfp.jpg";
                size = 150;
                rounding = -1;
                border_size = 5;
                border_color = "rgb(24, 25, 38)";
                position = "0, 60";
                halign = "center";
                valign = "center";
              }
            ];
            label = [
              {
                monitor = cfg.lockMonitor;
                text = "cmd[update:10000] echo '$USER' | tr '[:lower:]' '[:upper:]'";
                position = "0, -35";
                halign = "center";
                valign = "center";
              }
            ];
          };
        };
      };
    })
    (mkIf cfg.desktop {
      wayland.windowManager.hyprland.settings = {
        bindl = [
          ", Next, exec, playerctl play-pause"
          ", Prior, exec, playerctl next"
          "SHIFT, Prior, playerctl previous"
        ];
      };
      programs.waybar.settings = {
        mainbar = {
          output = "DP-1";
          modules-left = [
            "hyprland/workspaces"
            "custom/sep"
            "hyprland/window"
          ];
          modules-center = ["mpris"];
          modules-right = [
            "tray"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "clock"
            "custom/weather"
          ];
        };
        clockbar = {
          output = "DP-2";
          modules-left = ["hyprland/workspaces"];
          modules-center = ["clock"];
          modules-right = ["custom/weather"];
        };
      };
    })
    (mkIf cfg.laptop {
      programs.waybar.settings = {
        mainbar = {
          modules-left = [
            "hyprland/workspaces"
            "custom/sep"
            "hyprland/window"
          ];
          modules-center = ["mpris"];
          modules-right = [
            "tray"
            "pulseaudio"
            "network"
            "backlight"
            "battery"
            "clock"
            "custom/weather"
          ];
        };
      };
    })
  ];
}
