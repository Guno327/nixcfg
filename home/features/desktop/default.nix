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
    ./kitty.nix
  ];

  home.packages = with pkgs; [
    spotifywm
    dracula-theme
    dracula-icon-theme
  ];
}
