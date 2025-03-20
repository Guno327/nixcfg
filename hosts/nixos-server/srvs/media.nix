{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.media;
in {
  options.srvs.media.enable = mkEnableOption "Enable media service";

  config = mkIf cfg.enable {
    users = {
      users.media = {
        uid = 8096;
        name = "media";
        isSystemUser = true;
        home = "/home/media";
        group = "media";
      };
      groups.media = {
        gid = 8096;
        name = "media";
      };
    };
    systemd.tmpfiles.rules = [
      "d /home/media 774 media media -"
      "d /home/media/jellyfin 774 media media -"
      "d /home/media/jackett 774 media media -"
      "d /home/media/radarr 774 media media -"
      "d /home/media/sonarr 774 media media -"
      "d /home/media/torrent 774 media media -"
      "d /home/media/media 774 media media -"
    ];

    virtualisation.oci-containers.containers = {
      jellyfin = {
        autoStart = true;
        image = "lscr.io/linuxserver/jellyfin:latest";
        ports = ["8096:8096"];
        volumes = [
          "/home/media/jellyfin:/config"
          "/home/media/media:/data"
        ];
        environment = {
          PUID = "8096";
          PGID = "8096";
          TZ = "America/Denver";
        };
      };

      jackett = {
        autoStart = true;
        image = "lscr.io/linuxserver/jackett:latest";
        ports = ["9117:9117"];
        volumes = ["/home/media/jackett:/config"];
        environment = {
          PUID = "8096";
          PGID = "8096";
          TZ = "America/Denver";
          AUTO_UPDATE = "true";
        };
      };

      radarr = {
        autoStart = true;
        image = "lscr.io/linuxserver/radarr:latest";
        ports = ["7878:7878"];
        volumes = [
          "/home/media/radarr:/config"
          "/home/media/media:/media"
        ];
        environment = {
          PUID = "8096";
          PGID = "8096";
          TZ = "America/Denver";
        };
      };

      sonarr = {
        autoStart = true;
        image = "lscr.io/linuxserver/sonarr:latest";
        ports = ["8989:8989"];
        volumes = [
          "/home/media/sonarr:/config"
          "/home/media/media:/media"
        ];
        environment = {
          PUID = "8096";
          PGID = "8096";
          TZ = "America/Denver";
        };
      };

      ombi = {
        autoStart = true;
        image = "lscr.io/linuxserver/ombi:latest";
        ports = ["3579:3579"];
        volumes = ["/home/media/ombi:/config"];
        environment = {
          PUID = "8096";
          PGID = "8096";
          TZ = "America/Denver";
        };
      };

      torrent = {
        autoStart = true;
        privileged = true;
        image = "dyonr/qbittorrentvpn";
        ports = ["8080:8080" "8999:8999"];
        volumes = [
          "/home/media/torrent:/config"
          "/home/media/media:/media"
        ];
        environment = {
          VPN_ENABLED = "yes";
          VPN_TYPE = "wireguard";
          LAN_NETWORK = "10.0.0.0/24";
          PUID = "8096";
          PGID = "8096";
        };
      };
    };
  };
}
