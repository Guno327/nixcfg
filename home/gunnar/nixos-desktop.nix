{
  pkgs,
  inputs,
  ...
}: {
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
    inputs.custom-pkgs.packages."${system}".balatro-mobile-maker
    syncthing
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
      hyprland = {
        enable = true;
        desktop = true;
      };

      quickshell = {
        enable = true;
        desktop = true;
      };

      foot.enable = true;
      minecraft.enable = true;
      gammastep.enable = true;
      virt-manager.enable = true;
      ee2.enable = true;
      poetrade.enable = true;
      recording.enable = true;
      spotify.enable = true;
    };
  };

  programs = {
    fish.loginShellInit = ''
       set -x NIX_PATH nixpkgs=channel:nixos-unstable
       set -x NIX_LOG info

      if test (tty) = "/dev/tty1"
         exec Hyprland &> /dev/null
       end
    '';
  };
}
