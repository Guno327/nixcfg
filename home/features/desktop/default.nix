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
    ./minecraft.nix
    ./dracula-theme.nix
  ];

  home.packages = with pkgs; [
  ];
}
