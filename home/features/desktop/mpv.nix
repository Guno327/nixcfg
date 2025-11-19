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
  options.features.desktop.mpv.jellyfin.enable = mkEnableOption "enable jellyfin-mpv-shim configuration";
  config = mkMerge [
    (mkIf cfg.enable {
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
          modernz
        ];
      };
    })
    (mkIf cfg.jellyfin.enable {
      home.packages = with pkgs; [jellyfin-mpv-shim];
      services.jellyfin-mpv-shim = {
        enable = true;
        settings = {
          fullscreen = false;
          enable_osc = true;
          mpv_ext = true;
          mpv_ext_path = "/etc/profiles/per-user/${config.home.username}/bin/mpv";
          mpv_ext_no_ovr = false;
        };
      };
    })
  ];
}
