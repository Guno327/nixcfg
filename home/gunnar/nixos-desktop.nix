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
        ", preferred, auto, 1"
      ];

      workspace = [
      ];

      env = [
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
    mainbar.modules-right = [ "tray" "mpris" "pulseaudio" "network" ];
  };
}
