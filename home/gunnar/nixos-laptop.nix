{pkgs, ...}: {
  imports = [
    ./home.nix
    ../features/cli
    ../features/desktop
    ../common
  ];

  home.packages = with pkgs; [
    webcord
    obsidian
    feh
    prusa-slicer
  ];

  features = {
    cli = {
      fish.enable = true;
      ripgrep.enable = true;
      bat.enable = true;
      zoxide.enable = true;
      eza.enable = true;
      git.enable = true;
      fzf.enable = true;
      mpv.enable = true;
    };
    desktop = {
      hyprland.enable = true;
      waybar.enable = true;
      fonts.enable = true;
      ghostty.enable = false;
      kitty.enable = true;
      minecraft.enable = true;
      dracula-theme.enable = true;
      gammastep.enable = true;
      spotify.enable = true;
      virt-manager.enable = true;
      ee2.enable = true;
    };
  };

  wayland.windowManager.hyprland = {
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

      bindl = [
        ", Next, exec, playerctl play-pause"
        ", Prior, exec, playerctl next"
        "SHIFT, Prior, exec, playerctl previous"
      ];
    };
  };

  services.hyprpaper.settings = {
    preload = [
      "~/pictures/wallpaper.png"
    ];
    wallpaper = [
      "eDP-1, ~/pictures/wallpaper.png"
    ];
  };

  programs = {
    waybar.settings = {
      mainbar = {
        modules-left = [
          "clock"
          "custom/weather"
          "hyprland/workspaces"
        ];
        modules-center = [];
        modules-right = [
          "tray"
          "mpris"
          "pulseaudio"
          "network"
          "backlight"
          "battery"
        ];
      };
    };

    fish.loginShellInit = ''
       set -x NIX_PATH nixpkgs=channel:nixos-unstable
       set -x NIX_LOG info
       set -x TERMINAL kitty
       direnv hook fish | source

      if test (tty) = "/dev/tty1"
         exec Hyprland &> /dev/null
       end
    '';

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
          }
        ];
        image = [
          {
            monitor = "";
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
            monitor = "";
            text = "cmd[update:10000] echo '$USER' | tr '[:lower:]' '[:upper:]'";
            position = "0, -35";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
