{
  pkgs,
  ...
} :
{
  imports = [
    ./wayland.nix
    ./waybar.nix
    ./hyprland.nix
  ];

  home.packages = with pkgs; [
  ];
}
