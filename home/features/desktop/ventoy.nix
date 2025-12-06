{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.cli.ventoy;
in
{
  options.features.cli.ventoy.enable = mkEnableOption "enable ventoy configuration";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ventoy-full-gtk
    ];
    nixpkgs.config.permittedInsecurePackages = [
      "ventoy-gtk3-1.1.05"
    ];
  };
}
