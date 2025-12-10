{
  pkgs,
  inputs,
  ...
}: let
  startupScript = pkgs.writeScript "startup.sh" ''
    #!/usr/bin/env bash

    sleep 3
    xrandr --output DisplayPort-1 --mode 1920x1080 --rotate right
    xrandr --output DisplayPort-0 --right-of DisplayPort-1 --mode 2560x1440 --rate 165
    feh --bg-center /home/gunnar/Pictures/Wallpapers/bg.svg

    discord &
    firefox &
  '';
in {
  imports = [
    ./home.nix
    ../features/cli
    ../features/desktop
    ../common
  ];

  home.packages = with pkgs; [
    feh
    discord
    r2modman
    protonup-qt
    pkgs.stable.godot_4
    osu-lazer-bin
    wlr-randr
    xdg-desktop-portal-gtk
    inputs.custom-pkgs.packages."${stdenv.hostPlatform.system}".balatro-mobile-maker
    inputs.custom-pkgs.packages."${stdenv.hostPlatform.system}".balatro-multiplayer
    syncthing
    tor-browser
    waydroid-helper
    rusty-path-of-building
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
      monitor.enable = true;
      ssh.enable = true;
      gpg.enable = true;
      dev.enable = true;
    };
    desktop = {
      i3 = {
        enable = true;
        desktop = true;
        term = "alacritty";
        startup = "${builtins.toString startupScript} > /home/gunnar/.scripts/startup.log";
      };
      alacritty.enable = true;
      minecraft.enable = true;
      gammastep.enable = true;
      virt-manager.enable = true;
      ee2.enable = true;
      poetrade.enable = true;
      recording.enable = true;
      spotify.enable = true;
      mpv = {
        enable = true;
        jellyfin.enable = true;
      };
      firefox.enable = true;
    };
  };

  programs = {
    fish.loginShellInit = ''
       set -x NIX_PATH nixpkgs=channel:nixos-unstable
       set -x NIX_LOG info

      if test (tty) = "/dev/tty1"
         exec startx &> /dev/null
       end
    '';
  };
}
