{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.i3;
in {
  options.features.desktop.i3 = {
    enable = mkEnableOption "enable and configure i3";
    desktop = mkEnableOption "enable i3 for desktop use";
    laptop = mkEnableOption "enable i3 for laptop use";
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
        xorg.xrandr
        maim
        xclip
        i3lock-color
        feh
        playerctl
      ];

      services = {
        picom.enable = true;
        redshift = {
          enable = true;
          provider = "manual";
          latitude = "35.0";
          longitude = "-80.9";
        };
        polybar = {
          enable = true;

          package = pkgs.polybar.override {
            i3Support = true;
            alsaSupport = true;
            iwSupport = true;
            nlSupport = true;
          };

          settings = {
            "module/alsa" = {
              type = "internal/alsa";
              format-volume = "vol: <label-volume>";
              label-muted = "muted";
            };

            "module/backlight" = {
              type = "internal/backlight";
              format = "bl: <label>";
              use-actual-brightness = true;
              poll-interval = 0;
            };

            "module/battery" = {
              type = "internal/battery";
              poll-interval = 5;
              time-format = "%H:%M";
              format-charging = "bat: <label-charging>";
              format-discharging = "bat: <label-discharging>";
              label-charging = "+%percentage%%";
              label-discharging = "%percentage%% %time%";
            };

            "module/date" = {
              type = "internal/date";
              date = "%a, %b %d";
              time = "%H:%M";
              format = "<label>";
              label = "%date% %time%";
            };

            "module/i3" = {
              type = "internal/i3";
              format = "<label-state>";
              pin-workspaces = true;

              label-focused = "%index%";
              label-focused-foreground = "#313244";
              label-focused-background = "#89b4fa";
              label-focused-padding = 1;

              label-unfocused = "%index%";
              label-unfocused-foreground = "#cdd6f4";
              label-unfocused-background = "#313244";
              label-unfocused-padding = 1;

              label-urgent = "%index%";
              label-urgent-foreground = "#313244";
              label-urgent-background = "#f5c2e7";
              label-urgent-padding = 1;

              label-visible = "%index%";
              label-visible-foreground = "#cdd6f4";
              label-visible-background = "#313244";
              label-visible-padding = 1;
            };

            "module/wireless" = {
              type = "internal/network";
              interface-type = "wireless";
              format-connected = "<label-connected>";
              format-disconnected = "<label-disconnected>";
              format-packetloss = "!<label-connected>";
              label-connected = "%essid%: %downspeed%";
              label-disconnected = "%ifname%";
            };

            "module/wired" = {
              type = "internal/network";
              interface-type = "wired";
              format-connected = "<label-connected>";
              format-disconnected = "<label-disconnected>";
              format-packetloss = "!<label-connected>";
              label-connected = "%local_ip%: %downspeed%";
              label-disconnected = "%ifname%";
            };

            "module/tray" = {
              type = "internal/tray";
              format-margin = "8px";
              tray-spacing = "8px";
            };

            "module/window" = {
              type = "internal/xwindow";
              format = "<label>";
              label = "%title%";
              label-empty = "";
            };
          };
        };
      };

      xsession.windowManager.i3 = {
        enable = true;
        config = {
          bars = [];
          window.titlebar = false;
          gaps = {
            inner = 0;
            outer = 0;
          };

          startup = [
            {
              command = cfg.startup;
              notification = false;
            }
          ];
          assigns = {
            "2" = [
              {class = "firefox";}
            ];
            "3" = [{class = "steam";}];
            "6" = [{class = "discord";} {class = "WebCord";}];
          };

          fonts = mkOptionDefault {
            names = [
              "FiraCode Nerd Font"
              "Material Icons"
            ];
            style = "SemiBold";
            size = 12.0;
          };

          modifier = "Mod4";
          keybindings = let
            mod = config.xsession.windowManager.i3.config.modifier;
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
              "${mod}+Control+Up" = "resize grow height 10 px or 10 ppt";
              "${mod}+Control+Down" = "resize shrink height 10 px or 10 ppt";
              "${mod}+Control+Left" = "resize grow width 10 px or 10 ppt";
              "${mod}+Control+Right" = "resize shrink width 1 px or 1 ppt";
              "${mod}+Control+Shift+Up" = "resize grow height 1 px or 1 ppt";
              "${mod}+Control+Shift+Down" = "resize shrink height 1 px or 1 ppt";
              "${mod}+Control+Shift+Left" = "resize grow width 1 px or 1 ppt";
              "${mod}+Control+Shift+Right" = "resize shrink width 1 px or 1 ppt";

              "XF86MonBrightnessDown" = "exec brightnessctl --quiet s 10-";
              "XF86MonBrightnessUp" = "exec brightnessctl --quiet s +10";
              "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK 5%-";
              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              "XF86AudioPlay" = "exec playerctl play-pause";
              "XF86AudioPause" = "exec playerctl play-pause";
              "XF86AudioNext" = "exec playerctl next";
              "XF86AudioPrev" = "exec player previous";
              "Print" = "exec maim -s | xclip -selection clipboard -t image/png";

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

              "${mod}+l" = "exec i3lock --screen 1 --blur 5 --clock --indicator --inside-color='#ffffff22'";
              "${mod}+Return" = "exec ${cfg.term}";
            };
        };
      };
    })
    (mkIf cfg.desktop {
      xsession.windowManager.i3.config = {
        workspaceOutputAssign = [
          {
            workspace = "1";
            output = "DisplayPort-0";
          }
          {
            workspace = "2";
            output = "DisplayPort-0";
          }
          {
            workspace = "3";
            output = "DisplayPort-0";
          }
          {
            workspace = "4";
            output = "DisplayPort-0";
          }
          {
            workspace = "5";
            output = "DisplayPort-0";
          }
          {
            workspace = "6";
            output = "DisplayPort-1";
          }
          {
            workspace = "7";
            output = "DisplayPort-1";
          }
          {
            workspace = "8";
            output = "DisplayPort-1";
          }
          {
            workspace = "9";
            output = "DisplayPort-1";
          }
          {
            workspace = "0";
            output = "DisplayPort-1";
          }
        ];
      };

      services.polybar = {
        settings = {
          "module/wired" = {
            interface = "enp7s0";
          };

          "bar/primary" = {
            monitor = "DisplayPort-0";
            bottom = true;
            font-0 = "Fira Code:size=12;2";
            background = "#11111b";
            foreground = "#cdd6f4";
            modules-left = "i3";
            modules-center = "window";
            modules-right = "wired network alsa date tray";
            separator = " | ";
          };

          "bar/aux" = {
            monitor = "DisplayPort-1";
            bottom = true;
            font-0 = "Fira Code:size=12;2";
            background = "#11111b";
            foreground = "#cdd6f4";
            modules-left = "i3";
            modules-right = "date";
            separator = " | ";
          };
        };
        script = "polybar primary & polybar aux &";
      };
    })
    (mkIf cfg.laptop {
      xsession.windowManager.i3.config = {
        workspaceOutputAssign = [
          {
            workspace = "1";
            output = "eDP";
          }
          {
            workspace = "2";
            output = "eDP";
          }
          {
            workspace = "3";
            output = "eDP";
          }
          {
            workspace = "4";
            output = "eDP";
          }
          {
            workspace = "5";
            output = "eDP";
          }
          {
            workspace = "6";
            output = "eDP";
          }
          {
            workspace = "7";
            output = "eDP";
          }
          {
            workspace = "8";
            output = "eDP";
          }
          {
            workspace = "9";
            output = "eDP";
          }
          {
            workspace = "0";
            output = "HDMI-A-1-0";
          }
        ];
      };
      services.polybar = {
        settings = {
          "module/wireless" = {
            interface = "wlp4s0";
          };

          "module/battery" = {
            battery = "BAT1";
            adapter = "ADP1";
          };

          "bar/primary" = {
            monitor = "eDP";
            bottom = true;
            font-0 = "Fira Code:size=12;2";
            background = "#11111b";
            foreground = "#cdd6f4";
            modules-left = "i3";
            modules-center = "window";
            modules-right = "wireless network alsa backlight battery date tray";
            separator = " | ";
          };
        };
        script = "polybar primary &";
      };
    })
  ];
}
