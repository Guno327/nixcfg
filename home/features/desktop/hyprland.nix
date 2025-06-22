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
      dunst
      hyprshot
      hyprlock
      nautilus
      playerctl
      qt6.qtwayland
      waypipe
      wf-recorder
      wl-mirror
      wl-clipboard
      wleave
      wtype
      wttrbar
      wev
      xdg-desktop-portal-hyprland
      ydotool
      wdisplays
    ];

    programs.wofi.enable = true;
    services.hyprpaper.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        xwayland = {
          force_zero_scaling = true;
        };

        exec-once = [
          "waybar"
          "hyprpaper"
          ''wl-paste -p -t text --watch clipman store -P --histpath="~/.local/share/clipman-primary.json"''
          "fcitx5 -d -r"
          "fcitx5-remote -r"
        ];

        env = ["WLR_NO_HARDWARE_CURSORS,1"];

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
          "float, title:dunst"
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
          "float, title:^(Picture-in-Picture)$"
          "size 800 600, title:^(Volume Control)$"
          "move 75 44%, title:^(Volume Control)$"
          "pseudo, title:fcitx"
        ];

        "$mainMod" = "SUPER";

        bind = [
          "$mainMod, P, togglefloating"
          "$mainMod, C, killactive"
          "$mainMod, M, exec, wleave -p layer-shell"
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
          ", XF86MonBrightnessDown, exec, brightnessctl --quiet s 10-"
          ", XF86MonBrightnessUp, exec, brightnessctl --quiet s +10"
          ", Print, exec, hyprshot -m region -o /home/gunnar/pictures/screenshots"
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

        binde = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ];

        windowrulev2 = [
        ];
      };
    };
  };
}
