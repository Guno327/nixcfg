{
  pkgs,
  ...
} :
{
  imports = [
    ./wayland.nix
    ./waybar.nix
    ./hyprland.nix
    ./fonts.nix
  ];

  home.packages = with pkgs; [
  ];
}
