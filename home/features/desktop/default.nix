{
  pkgs,
  ...
} :
{
  imports = [
    ./wayland.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
  ];
}
