{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.spotify;
in {
  options.features.desktop.spotify.enable = mkEnableOption "Enable and configure spotify";

  config = mkIf cfg.enable {
    programs.spotify-player = {
      enable = true;
      settings = {
        enable_media_control = true;
        enable_notify = false;
      };
      keymaps = [
        {
          command = "Shuffle";
          key_sequence = "c s";
        }
        {
          command = "Repeat";
          key_sequence = "c r";
        }
        {
          command = "Quit";
          key_sequence = "c c";
        }
      ];
    };

    xdg.desktopEntries.spotify = {
      name = "Spotify";
      genericName = "spotify_player";
      exec = "foot -e spotify_player";
      terminal = false;
    };
  };
}
