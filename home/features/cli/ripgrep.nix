{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.cli.ripgrep;
in
{
  options.features.cli.ripgrep.enable = mkEnableOption "Enable and alias ripgrep";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ripgrep ];
    programs.fish.shellAbbrs = {
      grep = "rg";
    };
  };
}
