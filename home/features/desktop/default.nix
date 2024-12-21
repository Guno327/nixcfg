{
  pkgs,
  ...
} :
{
  imports = [
    ./wayland.nix
    ./waybar.nix
    ./wofi.nix
    ./hyprland.nix
    ./fonts.nix
  ];

  home.packages = with pkgs; [
    spotifywm
  ];
}
