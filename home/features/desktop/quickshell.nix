{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.desktop.quickshell;
in
{
  options.features.desktop.quickshell = {
    enable = mkEnableOption "enable config for quickshell";
    desktop = mkEnableOption "enable config for desktop use";
    laptop = mkEnableOption "enable config for laptop use";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.caelestia = {
        enable = true;

        systemd = {
          enable = false;
          target = "graphical-session.target";
          environment = [ ];
        };

        settings = {
          appearance.rounding.scale = 0.2;
          paths.wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
          notifs.actionOnClick = true;

          launcher = {
            actionPrefix = "/";
            actions = [
              {
                name = "Calculator";
                icon = "calculate";
                description = "Do maths";
                command = [
                  "autocomplete"
                  "calc"
                ];
                enabled = true;
              }
              {
                name = "Scheme";
                icon = "palette";
                description = "Change color theme";
                command = [
                  "autocomplete"
                  "scheme"
                ];
                enabled = true;
              }
              {
                name = "Wallpaper";
                icon = "image";
                description = "Change wallpaper";
                command = [
                  "autocomplete"
                  "wallpaper"
                ];
                enabled = true;
              }
              {
                name = "Variant";
                icon = "colors";
                description = "Change theme variant";
                command = [
                  "autocomplete"
                  "variant"
                ];
                enabled = true;
              }
              {
                name = "Shutdown";
                icon = "power_settings_new";
                description = "Power off";
                command = [
                  "systemctl"
                  "poweroff"
                ];
                enabled = true;
              }
              {
                name = "Logout";
                icon = "exit_to_app";
                description = "Exit shell";
                command = [
                  "loginctl"
                  "terminate-user"
                  ""
                ];
                enabled = true;
              }
              {
                name = "Reboot";
                icon = "cached";
                description = "Reboot system";
                command = [
                  "systemctl"
                  "reboot"
                ];
                enabled = true;
              }
              {
                name = "Lock";
                icon = "lock";
                description = "Lock shell";
                command = [ "hyprlock" ];
                enabled = true;
              }
            ];
          };

          general.idle = {
            lockBeforeSleep = false;
            timeouts = [
              {
                timeout = 180;
                idleAction = "hyprlock";
              }
            ];
          };

          services = {
            useFarenheit = false;
            useTwelveHourClock = false;
          };

          bar = {
            clock.showIcon = false;

            tray = {
              comapct = true;
              recolour = true;
            };

            entries = [
              {
                id = "logo";
                enabled = true;
              }
              {
                id = "workspaces";
                enabled = true;
              }
              {
                id = "spacer";
                enabled = true;
              }
              {
                id = "activeWindow";
                enabled = false;
              }
              {
                id = "spacer";
                enabled = true;
              }
              {
                id = "tray";
                enabled = true;
              }
              {
                id = "clock";
                enabled = true;
              }
              {
                id = "statusIcons";
                enabled = true;
              }
              {
                id = "power";
                enabled = true;
              }
            ];
          };
        };

        cli = {
          enable = true;
          settings = {
            theme.enableGtk = true;
          };
        };
      };

      wayland.windowManager.hyprland.settings = {
        exec-once = [
          "caelestia shell -d"
        ];

        bind = [
          "Super, L, exec, caelestia shell lock lock"
          "Super, D, exec, caelestia shell drawers toggle launcher"
          "Super, N, exec, caelestia shell drawers toggle sidebar"
          "Super, G, exec, caelestia gameMode toggle"
        ];

        bindl = [
          ", XF86AudioPlay, exec, caelestia shell mpris playPause"
          ", XF86AudioPause, exec, caelestia shell mpris playPause"
          ", XF86AudioNext, exec, caelestia shell mpris next"
          ", XF86AudioPrev, exec, caelestia shell mpris previous"
          ", XF86AudioStop, exec, caelestia shell mpris stop"
          ", Print, global, caelestia:screenshotFreeze"
        ];

        bindin = [
          "Super, mouse:272, global, caelestia:launcherInterrupt"
          "Super, mouse:273, global, caelestia:launcherInterrupt"
          "Super, mouse:274, global, caelestia:launcherInterrupt"
          "Super, mouse:275, global, caelestia:launcherInterrupt"
          "Super, mouse:276, global, caelestia:launcherInterrupt"
          "Super, mouse:277, global, caelestia:launcherInterrupt"
          "Super, mouse_up, global, caelestia:launcherInterrupt"
          "Super, mouse_down, global, caelestia:launcherInterrupt"
        ];
      };
    })
    (mkIf cfg.desktop {
      programs.caelestia.settings = {
        bar.status.showBattery = false;
      };
    })
    (mkIf cfg.laptop {
    })
  ];
}
