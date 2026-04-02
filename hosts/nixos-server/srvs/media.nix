{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.media;
  bitmagnet_workflow = pkgs.writeTextFile {
    name = "classifier.yml";
    text = ''
      $schema: "https://bitmagnet.io/schemas/classifier-0.1.json"
      classfier:
        workflow: custom 
        flags:
          delete_content_types:
            - comic 
            - software 
            - xxx 
            - audiobooks 
            - ebooks 
            - music

      workflows:
        custom:
          # Run the default classification first
          - run_workflow: default
          # Then apply custom filtering
          - if_else:
              condition: >
                result.contentType in [contentType.movie, contentType.tv_show] &&
                torrent.videos.filter(v, v.resolution == "1080p").size() > 0 &&
                torrent.audios.filter(a, a.language in ["eng", "jpn"]).size() > 0
              if_action:
                add_tag: "1080p-eng-jpn"
              else_action:
                delete
    '';
  };
in
{
  options.srvs.media = {
    enable = mkEnableOption "Setup and configure Nixarr";
  };

  config = mkIf cfg.enable {
    services.traefik.dynamicConfigOptions = mkIf config.srvs.traefik.enable {
      http = {
        routers = {
          media-router = {
            rule = "Host(`media.ghov.net`)";
            entryPoints = [ "websecure" ];
            priority = 10;
            service = "media-service";
          };
          request-router = {
            rule = "Host(`request.ghov.net`)";
            entryPoints = [ "websecure" ];
            priority = 10;
            service = "request-service";
          };
          sonarr-router = {
            rule = "Host(`sonarr.ghov.net`)";
            entryPoints = [ "websecure" ];
            priority = 10;
            service = "sonarr-service";
          };
          radarr-router = {
            rule = "Host(`radarr.ghov.net`)";
            entryPoints = [ "websecure" ];
            priority = 10;
            service = "radarr-service";
          };
          prowlarr-router = {
            rule = "Host(`prowlarr.ghov.net`)";
            entryPoints = [ "websecure" ];
            priority = 10;
            service = "prowlarr-service";
          };
        };
        services = {
          media-service.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:8096";
              preservePath = true;
            }
          ];
          request-service.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:5000";
              preservePath = true;
            }
          ];
          sonarr-service.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:8989";
              preservePath = true;
            }
          ];
          radarr-service.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:7878";
              preservePath = true;
            }
          ];
          prowlarr-service.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:9117";
              preservePath = true;
            }
          ];
        };
      };
    };

    sops.secrets = {
      bazarr = { };
      jellyfin = { };
      jellyseerr = { };
      prowlarr = { };
      radarr = { };
      sonarr = { };
      wireguard = {
        sopsFile = ../../../secrets/wg0.conf;
        format = "binary";
      };

      transmission = {
        sopsFile = ../../../secrets/transmission.json;
        format = "json";
        key = "";
      };
    };

    networking.firewall.trustedInterfaces = [ "wg-br" ];

    environment.systemPackages = with pkgs; [
      jellyfin-ffmpeg
    ];

    users.users = {
      jellyfin.extraGroups = [
        "video"
        "media"
      ];
      sonarr.extraGroups = [ "media" ];
      radarr.extraGroups = [ "media" ];
      bazarr.extraGroups = [ "media" ];
      transmission.extraGroups = [ "media" ];
      gunnar.extraGroups = [ "media" ];
    };

    services.flaresolverr.enable = true;

    nixarr = {
      enable = true;
      mediaDir = "/media";
      stateDir = "/media/.state/nixarr";

      vpn = {
        enable = true;
        wgConf = config.sops.secrets.wireguard.path;
      };

      jellyfin = {
        enable = true;
      };

      transmission = {
        enable = true;
        vpn.enable = true;
        peerPort = 8999;
        extraAllowedIps = [ "*" ];
        credentialsFile = config.sops.secrets.transmission.path;
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

    # Bitmagnet
    /*
      services = {
        bitmagnet = {
          enable = false;
          settings = {
            http_server.local_address = "0.0.0.0:3333";
            dht_server.port = 3334;
          };
        };

        postgresql = {
          enable = true;
          dataDir = "/media/postgresql/${config.services.postgresql.package.psqlSchema}";
        };
      };

      systemd.services.bitmagnet = {
        environment = {
          EXTRA_CONFIG_FILES = "${bitmagnet_workflow}";
        };
        serviceConfig.EnvironmentFile = [ config.sops.secrets.tmdb.path ];
        vpnConfinement = {
          enable = true;
          vpnNamespace = "wg";
        };
      };

      vpnNamespaces.wg = {
        portMappings = [
          {
            from = 3333;
            to = 3333;
          }
        ];
        openVPNPorts = [
          {
            port = 3334;
            protocol = "both";
          }
        ];
      };
    */
  };
}
