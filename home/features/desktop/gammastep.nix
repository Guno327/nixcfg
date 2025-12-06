{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.desktop.gammastep;
in
{
  options.features.desktop.gammastep.enable = mkEnableOption "Enable and configure gammastep";

  config = mkIf cfg.enable {
    services.gammastep = {
      enable = true;
      latitude = 40.76078;
      longitude = -111.891045;
      temperature = {
        day = 6000;
        night = 4000;
      };
      tray = true;
    };
  };
}
