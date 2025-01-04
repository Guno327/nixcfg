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
      background = [{
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }];
      input-field = [{
        monitor = "DP-1";
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
      image = [{
        monitor = "DP-1";
        path = "~/pictures/pfp.jpg";
        size = 150;
        rounding = -1;
        border_size = 5;
        border_color = "rgb(24, 25, 38)";
        position = "0, 60";
        halign = "center";
        valign = "center";
      }];
      label = [{
        monitor = "DP-1";
        text = "cmd[update:10000] echo '$USER' | tr '[:lower:]' '[:upper:]'";
        position = "0, -35";
        halign = "center";
        valign = "center";
      }];
    };
  };
}
