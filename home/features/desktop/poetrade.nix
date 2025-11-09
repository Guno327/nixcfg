{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.features.desktop.poetrade;
in {
  options.features.desktop.poetrade.enable = mkEnableOption "Enable and configure awakened poe trade";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [inputs.custom-pkgs.packages."${stdenv.hostPlatform.system}".awakened-poe-trade];

    xdg.desktopEntries.awakened-poe-trade = {
      name = "Awakened Poe Trade";
      exec = "awakened-poe-trade --no-overlay --listen=127.0.0.1:5000";
      icon = "awakened-poe-trade";
      type = "Application";
      comment = "Path of Exile overlay program for price checking";
    };
  };
}
