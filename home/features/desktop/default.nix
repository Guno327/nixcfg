{
  pkgs,
  ...
} :
{
  imports = [
    ./waybar.nix
    ./hyprland.nix
    ./fonts.nix
    ./kitty.nix
    ./minecraft.nix
    ./dracula-theme.nix
  ];

  home.packages = with pkgs; [
  ];
}
