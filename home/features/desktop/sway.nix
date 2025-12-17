{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.sway;
in {
  options.features.desktop.sway = {
    enable = mkEnableOption "enable and configure sway";
    desktop = mkEnableOption "enable sway for desktop use";
    laptop = mkEnableOption "enable sway for laptop use";
    term = mkOption {
      type = types.str;
      description = "Default Terminal";
      default = "xterm";
    };
    startup = mkOption {
      type = types.path;
      description = "Startup Script";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        librsvg
        wl-clipboard
        grim
        slurp
        swaylock-effects
        swaynotificationcenter
        wttrbar
        wofi
        playerctl
        swaybg
      ];

      services = {
        gnome-keyring.enable = true;
      };

      wayland.windowManager.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        systemd.variables = ["--all"];
        config = {
          modifier = "Mod4";
          terminal = cfg.term;
          bars = [];

          startup = [
            {command = "waybar";}
            {command = "swaync";}
            {command = "swaybg -m center -i /flake/home/common/bg.svg";}
            {command = cfg.startup;}
          ];

          assigns = {
            "2" = [{app_id = "firefox";}];
            "3" = [{app_id = "steam";}];
            "6" = [
              {app_id = "discord";}
              {app_id = "WebCord";}
            ];
          };

          window.commands = [
            {
              command = "inhibit_idle fullscreen";
              criteria = {app_id = "^.*";};
            }
          ];

          keybindings = let
            mod = config.wayland.windowManager.sway.config.modifier;
          in
            mkOptionDefault {
              "${mod}+v" = "floating toggle";
              "${mod}+c" = "kill";
              "${mod}+f" = "fullscreen toggle";
              "${mod}+Left" = "focus left";
              "${mod}+Right" = "focus right";
              "${mod}+Up" = "focus up";
              "${mod}+Down" = "focus down";
              "${mod}+Shift+Left" = "move left";
              "${mod}+Shift+Right" = "move right";
              "${mod}+Shift+Up" = "move up";
              "${mod}+Shift+Down" = "move down";
              "${mod}+Control+Up" = "resize grow height 1 px or 1 ppt";
              "${mod}+Control+Down" = "resize shrink height 1 px or 1 ppt";
              "${mod}+Control+Left" = "resize grow width 1 px or 1 ppt";
              "${mod}+Control+Right" = "resize shrink width 1 px or 1 ppt";

              "XF86MonBrightnessDown" = "exec brightnessctl --quiet s 10-";
              "XF86MonBrightnessUp" = "exec brightnessctl --quiet s +10";
              "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK 5%-";
              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              "XF86AudioPlay" = "exec playerctl play-pause";
              "XF86AudioPause" = "exec playerctl play-pause";
              "XF86AudioNext" = "exec playerctl next";
              "XF86AudioPrev" = "exec player previous";
              "Print" = "exec slurp | grim -g - - | wl-copy";

              "${mod}+1" = "workspace number 1";
              "${mod}+2" = "workspace number 2";
              "${mod}+3" = "workspace number 3";
              "${mod}+4" = "workspace number 4";
              "${mod}+5" = "workspace number 5";
              "${mod}+6" = "workspace number 6";
              "${mod}+7" = "workspace number 7";
              "${mod}+8" = "workspace number 8";
              "${mod}+9" = "workspace number 9";
              "${mod}+0" = "workspace number 0";
              "${mod}+Shift+1" = "move container to workspace number 1";
              "${mod}+Shift+2" = "move container to workspace number 2";
              "${mod}+Shift+3" = "move container to workspace number 3";
              "${mod}+Shift+4" = "move container to workspace number 4";
              "${mod}+Shift+5" = "move container to workspace number 5";
              "${mod}+Shift+6" = "move container to workspace number 6";
              "${mod}+Shift+7" = "move container to workspace number 7";
              "${mod}+Shift+8" = "move container to workspace number 8";
              "${mod}+Shift+9" = "move container to workspace number 9";
              "${mod}+Shift+0" = "move container to workspace number 0";

              "${mod}+r" = "reload";
              "${mod}+Shift+r" = "restart";

              "${mod}+d" = "exec wofi --show drun";
              "${mod}+n" = "exec swaync-client -t -sw";
              "${mod}+Return" = "exec ${cfg.term}";
              "${mod}+l" = ''
                exec swaylock \
                --screenshots \
                --clock \
                --indicator \
                --indicator-radius 100 \
                --indicator-thickness 7 \
                --effect-blur 7x5 \
                --effect-vignette 0.5:0.5 \
                --fade-in 0.2
              '';
            };
        };
      };

      programs = {
        waybar = {
          enable = true;
          settings = {
            mainbar = {
              layer = "top";
              position = "bottom";
              mod = "dock";
              exclusive = true;
              passthrough = false;
              gtk-layer-shell = true;
              height = 0;

              "sway/workspaces" = {
                all-outputs = false;
                format = "{index}";
                disable-scroll = true;
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
    })
    (mkIf cfg.desktop {
      wayland.windowManager.sway.config = {
        output = {
          "DP-1" = {
            mode = "2560x1440@165.080Hz";
            pos = "1080 220";
            adaptive_sync = "on";
          };
          "DP-2" = {
            mode = "1920x1080@60.000Hz";
            pos = "0 0";
            transform = "90";
          };
        };

        workspaceOutputAssign = [
          {
            workspace = "1";
            output = "DP-1";
          }
          {
            workspace = "2";
            output = "DP-1";
          }
          {
            workspace = "3";
            output = "DP-1";
          }
          {
            workspace = "4";
            output = "DP-1";
          }
          {
            workspace = "5";
            output = "DP-1";
          }
          {
            workspace = "6";
            output = "DP-2";
          }
          {
            workspace = "7";
            output = "DP-2";
          }
          {
            workspace = "8";
            output = "DP-2";
          }
          {
            workspace = "9";
            output = "DP-2";
          }
          {
            workspace = "0";
            output = "DP-2";
          }
        ];
      };

      programs.waybar.settings = {
        mainbar = {
          output = "DP-1";
          modules-left = [
            "sway/workspaces"
          ];
          modules-center = [
            "mpris"
          ];
          modules-right = [
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "clock"
            "tray"
          ];
        };
        clockbar = {
          output = "DP-2";
          position = "bottom";
          modules-left = ["sway/workspaces"];
          modules-right = ["clock"];
        };
      };
    })
    (mkIf cfg.laptop {
      })
  ];
}
