{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.mpv;
in {
  options.features.cli.mpv.enable = mkEnableOption "enable extended mpv configuration";
  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      config = {
        profile = "gpu-hq";
        force-window = true;
        ytdl-format = "bestvideo+bestaudio";
        cache-default = 4000000;

        save-position-on-quit = true;
        resume-playback = true;
      };
      scripts = with pkgs.mpvScripts; [
        mpris
        modernz
        smartskip
        memo
        autosub
      ];
    };
  };
}
