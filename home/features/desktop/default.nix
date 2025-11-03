{pkgs, ...}: {
  imports = [
    ./hyprutils.nix
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
    ./quickshell.nix
  ];

  home.packages = with pkgs; [
    wireshark
    freecad
    stable.gimp
    qFlipper
    audacity
  ];
}
