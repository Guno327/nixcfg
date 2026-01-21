{
  pkgs,
  lib,
  ...
}: let
  startupScript = pkgs.writeScript "startup.sh" ''
    #!/usr/bin/env bash
    xrandr --output eDP --mode 1920x1080 --rate 240 --primary
    feh --bg-tile /flake/home/common/bg.svg
    polybar primary &
  '';
in {
  imports = [
    ./home.nix
    ../features/cli
    ../features/desktop
    ../common
  ];

  home.packages = with pkgs; [
    discord
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
      gpg.enable = true;
      fzf.enable = true;
      ssh.enable = true;
      dev.enable = true;
    };
    desktop = {
      i3 = {
        enable = true;
        laptop = true;
        term = "alacritty";
        startup = "${toString startupScript} > /home/gunnar/.scripts/startup.log";
      };
      alacritty.enable = true;
      minecraft.enable = true;
      spotify.enable = true;
      firefox.enable = true;
    };
  };

  programs.fish.loginShellInit = ''
    set -x NIX_PATH nixpkgs=channel:nixos-unstable
    set -x NIX_LOG info
  '';

  programs.alacritty.settings.font.size = lib.mkForce 12;
}
