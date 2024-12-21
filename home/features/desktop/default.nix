{
  pkgs,
  ...
} :
{
  imports = [
    ./waybar.nix
    ./wofi.nix
    ./hyprland.nix
    ./fonts.nix
    ./kitty.nix
  ];

  home.packages = with pkgs; [
  ];
}
