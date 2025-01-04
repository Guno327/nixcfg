{ pkgs, ... }: { 
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
      lvim.enable = true;
      trim.enable = true;
    };
    desktop = {
      hyprland.enable = true;
      waybar.enable = true;
      fonts.enable = true;
      kitty.enable = true;
      minecraft.enable = true;
      dracula-theme.enable = true;
      gammastep.enable = true;
      spotify.enable = true;
      firefox.enable = true;
      virt-manager.enable = true;
    };
  };

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
        "5, monitor:DP-2"
        "6, monitor:DP-2"
      ];

      env = [
      ];

      bindl = [
        ", Next, exec, playerctl play-pause"
        ", Prior, exec, playerctl next"
        "SHIFT, Prior, exec, playerctl previous"
      ];

      exec-once = [
        "[workspace 1 silent] kitty"
        "[workspace 2 silent] zen"
        "[workspace 5 silent] webcord"
      ];

    };
  };


  programs.waybar.settings = {
    mainbar.output = "DP-1";

    mainbar.modules-left = ["clock" "custom/weather" "hyprland/workspaces"];
    mainbar.modules-center = [];
    mainbar.modules-right = [ "tray" "mpris" "pulseaudio" "network" "cpu" "memory" ];
  };
}
