{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.i3;
  status = pkgs.bumblebee-status.override {plugins = p: [p.nic p.pipewire];};
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
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        xorg.xrandr
        maim
        xclip
        i3lock-color
        feh
        status
      ];

      services.picom = {
        enable = true;
        vSync = true;
      };

      xsession.windowManager.i3 = {
        enable = true;
        config = {
          bars = [];
          gaps = {
            inner = 0;
            outer = 0;
          };

          assigns = {
            "2" = [{class = "zen";}];
            "3" = [{class = "steam";}];
            "6" = [{class = "discord";}];
          };

          fonts = mkOptionDefault {
            names = ["FiraCode Nerd Font" "Material Icons"];
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

              "XF86MonBrightnessDown" = "exec brightnessctl --quiet s 10-";
              "XF86MonBrightnessUp" = "exec brightnessctl --quiet s +10";
              "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume" = "exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK 5%-";
              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
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
      services.autorandr.enable = true;
      programs.autorandr = {
        enable = true;
        hooks.postswitch.i3 = "${pkgs.i3}/bin/i3-msg restart";
        profiles = {
          "default" = {
            fingerprint = {
              DisplayPort-0 = "00ffffffffffff0010acd9414c4a5241081f0104b53c22783b8cb5af4f43ab260e5054a54b00d100d1c0b300a94081808100714fe1c0565e00a0a0a029503020350055502100001a000000ff00334452545038330a2020202020000000fc0044454c4c205332373231444746000000fd0030a5fafa41010a202020202020014c020337f1513f101f200514041312110302010607151623090707830100006d1a0000020b30a5000f623d623de305c000e606050162623ef4fb0050a0a028500820680055502100001a40e7006aa0a067500820980455502100001a6fc200a0a0a055503020350055502100001a000000000000000000000000000000000000a5";
              DisplayPort-1 = "00ffffffffffff0038a3072b000000000e180104a5362078e22195a756529c26105054bfef8081008140818081c095009040b300a9c0023a801871382d40582c45001f3d2100001e000000fd00374c1f5311000a202020202020000000fc0045323433574d690a2020202020000000ff0034343130373231324e410a202001b1020313c1469004031f13122309070783010000011d007251d01e206e2855001f3d2100001e8c0ad08a20e02d10103e96001f3d210000188c0ad090204031200c4055001f3d21000018023a80d072382d40102c45801f3d2100001e00000000000000000000000000000000000000000000000000000000000000000000000011";
            };
            config = {
              DisplayPort-0 = {
                enable = true;
                primary = true;
                position = "1080x220";
                mode = "2560x1440";
                rate = "165.00";
              };
              DisplayPort-1 = {
                enable = true;
                primary = false;
                position = "0x0";
                mode = "1920x1080";
                rate = "60.00";
                rotate = "right";
              };
            };
          };
        };
      };

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
        startup = [
          {
            command = "feh --bg-center ${config.home.homeDirectory}/Pictures/Wallpapers/bg-0.png --bg-center ${config.home.homeDirectory}/Pictures/Wallpapers/bg-1.png";
            notification = false;
          }
          {command = "discord";}
          {command = "flatpak run app.zen_browser.zen";}
        ];
        bars = [
          {
            id = "main";
            position = "bottom";
            trayOutput = "primary";
            statusCommand = ''
              ${status}/bin/bumblebee-status \
                -m network ping pipewire datetime \
                -p interval=1 datetime.format=" %a, %b %-d %H:%M" ping.address=1.1.1.1
            '';
            extraConfig = "output primary";
            fonts = {
              names = ["FiraCode Nerd Font" "Material Icons"];
              style = "Regular";
              size = 12.0;
            };
          }
          {
            id = "2";
            position = "bottom";
            trayOutput = "none";
            statusCommand = ''
              ${status}/bin/bumblebee-status \
              -m datetime -p datetime.format="%a, %b %-d %H:%M"
            '';
            extraConfig = "output nonprimary";
            fonts = {
              names = ["FiraCode Nerd Font" "Material Icons"];
              style = "Regular";
              size = 12.0;
            };
          }
        ];
      };
    })
    (mkIf cfg.laptop {
      })
  ];
}
