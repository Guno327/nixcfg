{pkgs, ...}: {
  imports = [
    ./eza.nix
    ./zoxide.nix
    ./ripgrep.nix
    ./bat.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./trim.nix
    ./mpv.nix
    ./monitor.nix
  ];

  home.packages = with pkgs; [
    coreutils
    fd
    btop
    procs
    zip
    unzip
    neofetch
    brightnessctl
    speedtest-cli
    git
    lshw
    tealdeer
    ncdu
    termshark
    traceroute
    dig
    ventoy
    nix-prefetch-git
    nix-prefetch-github
    p7zip
    unrar
    android-file-transfer
    usbutils
    octave
    ntfs3g
    nix-index
    rclone
  ];
}
