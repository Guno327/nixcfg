{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.srvs.media;
in {
  options.srvs.media = {
    enable = mkEnableOption "Setup and configure Nixarr";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      jellyfin-ffmpeg
    ];

    users.users.jellyfin.extraGroups = [
      "video"
    ];

    users.users.gunnar.extraGroups = [
      "media"
    ];

    services.flaresolverr = {
      enable = true;
      port = 8191;
    };

    nixarr = {
      enable = true;
      mediaDir = "/storage";
      stateDir = "/var/lib/media/.state/nixarr";

      vpn = {
        enable = true;
        wgConf = "/flake/secrets/wg0.conf";
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
