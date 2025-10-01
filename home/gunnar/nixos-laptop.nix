{pkgs, ...}: {
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
      dev.enable = true;
    };
    desktop = {
      hyprland = {
        enable = true;
        laptop = true;
      };

      quickshell = {
        enable = true;
        laptop = true;
      };

      foot.enable = true;
      minecraft.enable = true;
      spotify.enable = true;
      virt-manager.enable = true;
      ee2.enable = true;
    };
  };

  programs.fish.loginShellInit = ''
     set -x NIX_PATH nixpkgs=channel:nixos-unstable
     set -x NIX_LOG info

    if test (tty) = "/dev/tty1"
       exec Hyprland &> /dev/null
     end
  '';
}
