{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.spotify;
in {
  options.features.desktop.spotify.enable = mkEnableOption "Enable and configure spotify";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [spotify-qt spotifyd];

    services.spotifyd = {
      settings.global = {
        username = "gunnarhovik-us";
        password = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/spotify.password);
      };
    };
  };
}
