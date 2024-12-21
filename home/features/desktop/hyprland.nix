{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let 
  cfg = config.features.desktop.hyprland;
  in {
    options.features.desktop.hyprland.enable = mkEnableOption "enable and configure hyprland";

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        spotifywm
        hyprshot
        hyprlock
        brave
        dunst
        nautilus
        xdg-desktop-portal
        qt6.qtwayland
        waypipe
        wf-recorder
        wl-mirror
        wl-clipboard
        wlogout
        wtype
        wttrbar
        ydotool
      ];

      gtk = {
        enable = true;
        cursorTheme = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 14;
        };
        theme = {
          package = pkgs.dracula-theme;
          name = "Dracula";
        };
        iconTheme = {
          package = pkgs.dracula-icon-theme;
          name = "Dracula";
        };
      };

      qt = {
        enable = true;
        style = {
          package = pkgs.dracula-qt5-theme;
          name = "dracula-theme";
        };
      };

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
          }];
          input-field = [
          {
            monitor = "";
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
          }];
          image = [
          {
            monitor = "";
            path = "~/Pictures/pfp.jpg";
            size = 150;
            rounding = -1;
            border_size = 5;
            border_color = "rgb(24, 25, 38)";
            position = "0, 80";
            halign = "center";
            valign = "center";
          }];
          label = [
          {
            monitor = "";
            text = "cmd[update:10000] echo '$USER' | tr '[:lower:]' '[:upper:]'";
            position = "0, -20";
            halign = "center";
            valign = "center";
          }];
        };
      };

      services.hyprpaper = {
        enable = true;
        settings = {
          preload = [ "~/Pictures/wallpaper.png" ];
          wallpaper = [ "eDP-1,~/Pictures/wallpaper.png" ];
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
	      settings = {
          xwayland = {
          force_zero_scaling = true;
        };

        exec-once = [
          "waybar"
          "hyprpaper"
          "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
        ];

        env = [
          "WLR_NO_HARDWARE_CURSORS,1"
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
          "col.active_border" = "rgba(9742b5ee) rgba(9742b5ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          allow_tearing = false;
	        layout = "dwindle";
        };

        decoration = {
          rounding = 8;
          blur = {
            enabled = true;
            size = 3;
            passes = 3;
          };
          active_opacity = 1.0;
          inactive_opacity = 0.9;
        };

        animations = {
          enabled = true;
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

        gestures = {
          workspace_swipe = false;
        };

        windowrule = [
          "float, file_progress"
          "float, confirm"
          "float, dialog"
          "float, download"
          "float, notification"
          "float, error"
          "float, splash"
          "float, confirmreset"
          "float, title:Open File"
          "float, title:branchdialog"
          "float, Lxappearance"
          "float, Wofi"
          "float, dunst"
          "animation none,Wofi"
          "float,viewnior"
          "float,feh"
          "float, pavucontrol-qt"
          "float, pavucontrol"
          "float, file-roller"
          "fullscreen, wlogout"
          "float, title:wlogout"
          "fullscreen, title:wlogout"
          "idleinhibit focus, mpv"
          "idleinhibit fullscreen, firefox"
          "float, title:^(Media viewer)$"
          "float, title:^(Volume Control)$"
          "float, title:^(Picture-in-Picture)$"
          "size 800 600, title:^(Volume Control)$"
          "move 75 44%, title:^(Volume Control)$"
        ];

        "$mainMod" = "SUPER";

        bind = [
          "$mainMod, RETURN, exec, kitty -e fish -c 'neofetch; exec fish'"
          "$mainMod, P, togglefloating"
          "$mainMod, C, killactive"
          "$mainMod, M, exec, wlogout -p layer-shell"
          "$mainMod, F, fullscreen"
          "$mainMod, V, togglefloating"
          "$mainMod, D, exec, wofi --show drun"
          "$mainMod SHIFT, P, pseudo"
          "$mainMod, J, togglesplit"
          "$mainMod, L, exec, hyprlock"
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          ", XF86MonBrightnessUp, exec, light -A 5"
          ", XF86MonBrightnessDown, exec, light -A 5"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        bindl = [
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        windowrulev2 = [
	];
      };
    };
  };
}
