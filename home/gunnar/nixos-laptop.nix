{ 
  imports = [ 
    ./home.nix
    ./repos
    ../features/cli
    ../features/desktop
    ../common 
  ];

  features = {
    cli = {
      fish.enable = true;
      git.enable = true;
      fzf.enable = true;
      neofetch.enable = true;
    };
    desktop = {
      hyprland.enable = true;
      waybar.enable = true;
      fonts.enable = true;
      kitty.enable = true;
      minecraft.enable = true;
      dracula-theme.enable = true;
      gammastep.enable = true;
      firefox.enable = true;
      spotify.enable = true;
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


  programs.waybar.settings = {
    mainbar.modules-left = ["clock" "custom/weather" "hyprland/workspaces"];
    mainbar.modules-center = [];
    mainbar.modules-right = ["tray" "mpris" "pulseaudio" "network" "backlight" "battery"];
  };
}
