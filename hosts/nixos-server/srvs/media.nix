{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.media;
in {
  options.srvs.media = {
    enable = mkEnableOption "Setup and configure Nixarr";
  };

  config = mkIf cfg.enable {
    nixarr = {
      enable = true;
      mediaDir = "/var/lib/media";
      stateDir = "/var/lib/media/.state/nixarr";

      vpn = {
        enable = true;
        wgConf = "/home/gunnar/.nixcfg/secrets/wg0.conf";
      };

      jellyfin = {
        enable = true;
      };

      transmission = {
        enable = true;
        vpn.enable = true;
        peerPort = 8999;
      };

      sonarr = {
        enable = true;
      };

      radarr = {
        enable = true;
      };

      bazarr = {
        enable = true;
      };

      prowlarr = {
        enable = true;
        port = 9117;
      };

      jellyseerr = {
        enable = true;
        port = 5000;
      };
    };
  };
}
