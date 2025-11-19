{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.mpv;
in {
  options.features.desktop.mpv.enable = mkEnableOption "enable extended mpv configuration";
  config = mkIf cfg.enable {
    services.jellyfin-mpv-shim.enable = true;
    programs.mpv = {
      enable = true;
      config = {
        profile = "gpu-hq";
        force-window = true;
        cache-default = 4000000;

        save-position-on-quit = true;
        resume-playback = true;
        osc = "no";
      };
      scripts = with pkgs.mpvScripts; [
        mpris
        mpv-osc-modern
      ];
    };
  };
}
