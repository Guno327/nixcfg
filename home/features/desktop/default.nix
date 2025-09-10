{pkgs, ...}: {
  imports = [
    ./waybar.nix
    ./hyprland.nix
    ./kitty.nix
    ./minecraft.nix
    ./gammastep.nix
    ./firefox.nix
    ./spotify.nix
    ./virt-manager.nix
    ./ghostty.nix
    ./ee2.nix
    ./poetrade.nix
    ./recording.nix
    ./foot.nix
    ./gnome.nix
  ];

  home.packages = with pkgs; [
    rpi-imager
    wireshark
    libreoffice-still
    freecad
    stable.gimp
    qFlipper
  ];
}
