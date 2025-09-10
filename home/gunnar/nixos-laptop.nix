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
      ai.enable = true;
    };
    desktop = {
      gnome.enable = true;
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
    set -x TERM xterm-256color
    direnv hook fish | source
  '';
}
