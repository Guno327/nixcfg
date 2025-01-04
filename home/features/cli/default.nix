{pkgs, ...}: {
  imports = [
    ./eza.nix
    ./zoxide.nix
    ./ripgrep.nix
    ./bat.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./lvim.nix
    ./trim.nix
  ];  

  home.packages = with pkgs; [
    coreutils
    fd
    btop
    httpie
    procs
    tldr
    zip
    unzip
    clang
    rustc
    cargo
    neofetch
    brightnessctl
    speedtest-cli
    git
    lshw
    s-tui
  ];

}
