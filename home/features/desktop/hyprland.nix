{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;
in {
  options.features.desktop.hyprland = {
    enable = mkEnableOption "enable and configure hyprland";
    desktop = mkEnableOption "enable hyprland for desktop use";
    laptop = mkEnableOption "enable hyprland for laptop use";
    lockMonitor = mkOption {
      type = types.str;
      default = "DP-1";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        hyprshot
        hyprcursor
        nautilus
        qt6.qtwayland
        waypipe
        wf-recorder
        wl-mirror
        wl-clipboard
        wtype
        wttrbar
        wev
        xdg-desktop-portal-hyprland
        ydotool
        wdisplays
      ];

      programs.hyprlock = {
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
              path = "${config.home.homeDirectory}/.face";
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

      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          xwayland = {
            force_zero_scaling = true;
          };

          exec-once = [
            ''wl-paste -p -t text --watch clipman store -P --histpath="~/.local/share/clipman-primary.json"''
            "fcitx5 -d -r"
            "fcitx5-remote -r"
          ];

          env = [
            "WLR_NO_HARDWARE_CURSORS,1"
            "HYPRCURSOR_THEME,Bibata-Modern-Classic"
            "HYPRCURSOR_SIZE,16"
          ];

          input = {
            kb_layout = "us";
            kb_variant = "";
            kb_model = "";
            kb_rules = "";
            kb_options = "";
            follow_mouse = 1;

            touchpad = {
              natural_scroll = true;
            };

            sensitivity = 0;
          };

          general = {
            gaps_in = 0;
            gaps_out = 0;
            border_size = 2;
            allow_tearing = false;
            layout = "dwindle";
          };

          decoration = {
            rounding = 8;
            blur = {
              enabled = false;
              size = 3;
              passes = 3;
              ignore_opacity = true;
            };
          };

          animations = {
            enabled = false;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          master = {};

          windowrule = [
            "float, title:file_progress"
            "float, title:confirm"
            "float, title:dialog"
            "float, title:download"
            "float, title:notification"
            "float, title:error"
            "float, title:splash"
            "float, title:confirmreset"
            "float, title:Open File"
            "float, title:branchdialog"
            "float, title:Lxappearance"
            "float, title:Wofi"
            "float, title:swaync"
            "animation none, title:Wofi"
            "float, title:viewnior"
            "float, title:feh"
            "float, title:pavucontrol-qt"
            "float, title:pavucontrol"
            "float, title:file-roller"
            "fullscreen, title:wlogout"
            "float, title:wlogout"
            "fullscreen, title:wlogout"
            "idleinhibit focus, title:mpv"
            "idleinhibit fullscreen, title:firefox"
            "float, title:^(Media viewer)$"
            "float, title:^(Volume Control)$"
            "size 800 600, title:^(Volume Control)$"
            "move 75 44%, title:^(Volume Control)$"
            "pseudo, title:fcitx"
            "monitor DP-2, tile, initialClass:app.zen_browser.zen initialTitle:Picture-in-Picture"
          ];

          bind = [
            "Super, P, togglefloating"
            "Super, C, killactive"
            "Super, F, fullscreen"
            "Super, V, togglefloating"
            "Shift+Super, P, pseudo"
            "Super, J, togglesplit"
            "Super, L, exec, hyprlock"
            "Super, left, movefocus, l"
            "Super, right, movefocus, r"
            "Super, up, movefocus, u"
            "Super, down, movefocus, d"
            ", XF86MonBrightnessDown, exec, brightnessctl --quiet s 10-"
            ", XF86MonBrightnessUp, exec, brightnessctl --quiet s +10"
            ", Print, exec, hyprshot -m region -o /home/gunnar/pictures/screenshots"
            "Super, 1, workspace, 1"
            "Super, 2, workspace, 2"
            "Super, 3, workspace, 3"
            "Super, 4, workspace, 4"
            "Super, 5, workspace, 5"
            "Super, 6, workspace, 6"
            "Super, 7, workspace, 7"
            "Super, 8, workspace, 8"
            "Super, 9, workspace, 9"
            "Super, 0, workspace, 10"
            "Shift+Super, 1, movetoworkspace, 1"
            "Shift+Super, 2, movetoworkspace, 2"
            "Shift+Super, 3, movetoworkspace, 3"
            "Shift+Super, 4, movetoworkspace, 4"
            "Shift+Super, 5, movetoworkspace, 5"
            "Shift+Super, 6, movetoworkspace, 6"
            "Shift+Super, 7, movetoworkspace, 7"
            "Shift+Super, 8, movetoworkspace, 8"
            "Shift+Super, 9, movetoworkspace, 9"
            "Shift+Super, 0, movetoworkspace, 10"
          ];

          bindm = [
            "Super, mouse:272, movewindow"
            "Super, mouse:273, resizewindow"
          ];

          binde = [
            ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ];

          windowrulev2 = [
          ];

          debug = {
            disable_logs = false;
          };
        };
      };
    })
    (mkIf cfg.desktop {
      wayland.windowManager.hyprland = {
        settings = {
          monitor = [
            "DP-1, 2560x1440@165, 1080x0, 1"
            "DP-2, 1920x1080@60, 0x0, 1, transform, 3"
          ];

          workspace = [
            "1, monitor:DP-1"
            "2, monitor:DP-1"
            "3, monitor:DP-1"
            "4, monitor:DP-1"
            "5, monitor:DP-1"
            "6, monitor:DP-2"
            "7, monitor:DP-2"
            "8, monitor:DP-2"
            "9, monitor:DP-2"
            "0, monitor:DP-2"
          ];

          env = [];

          exec-once = [
            # Primary Monitor Work-around
            "wlr-randr --output DP-2 --off && sleep 3 && wlr-randr --output DP-2 --on --pos 0,0"

            "[workspace 1 silent] foot"
            "[workspace 2 silent] flatpak run app.zen_browser.zen"
            "[workspace 6 silent] discord"
          ];

          windowrule = [
            "workspace 6, class:discord"
          ];
        };
      };
    })
    (mkIf cfg.laptop {
      wayland.windowManager.hyprland = {
        xwayland.enable = true;
        settings = {
          monitor = [
            "eDP-1,1920x1080@240,0x0,1"
            ",preferred, auto, 1, mirror, eDP-1"
          ];

          workspace = [
            "1, monitor:eDP-1, default:true"
            "2, monitor:eDP-1"
            "3, monitor:eDP-1"
            "4, monitor:eDP-1"
            "5, monitor:eDP-1"
          ];

          env = [
            "WLR_DRM_DEVICES,/dev/dri/card2"
            "AQ_DRM_DEVICES,/dev/dri/card2"
          ];
        };
      };
    })
  ];
}
