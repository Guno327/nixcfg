{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.ee2;
in
{
  options.features.desktop.ee2.enable = mkEnableOption "Enable and configure exiled exchange";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ exiled-exchange-2 ];

    xdg.desktopEntries.exiled-exchange-2 = {
      name = "Exiled Exchange 2";
      exec = "exiled-exchange-2 --no-overlay --listen=127.0.0.1:5000";
      icon = "exiled-exchange-2";
      type = "Application";
      comment = "Path of Exile 2 overlay program for price checking";
    };
  };
}
