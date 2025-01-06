{ config, lib, ... }: with lib;
let 
  cfg = config.srvs.media;
in {
  options.srvs.media.enable = mkEnableOption "Enable media service";
  
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /home/media 774 gunnar users -"
      "d /home/media/data 774 gunnar users -"
      "d /home/media/media 774 gunnar users -"
    ];

    containers.media = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.0.0.4/24";
      
      bindMounts = {
        "/data" = {
          hostPath = "/home/media/data";
          isReadOnly = false;
        };
        "/media" = {
          hostPath = "/home/media/media";
          isReadOnly = false;
        };
      };

      config = { config, pkgs, lib, ... }:{
        users = {
          users.media = {
            uid = 1000;
            isSystemUser = true;
            description = "media";
            group = "media";
          };
          groups.media = { 
            gid = 1000;
            members = [
              "media"
              "jellyfin"
              "jackett"
              "radarr"
              "sonarr"
              "torrent"
              "ombi"
            ];
          };
        };
    
        systemd.tmpfiles.rules = [
          "d /media 774 jellyfin media -"
          "d /media/movie 774 jellyfin media -"
          "d /media/tv 774 jellyfin media -"
          "d /media/anime 774 jellyfin media -"
          "d /media/download 774 deluge media -"
          "d /data 774 jellyfin media -"
          "d /data/jackett 774 jackett media -"
          "d /data/radarr 774 radarr media -"
          "d /data/sonarr 774 sonarr media -"
          "d /data/ombi 774 ombi media -"
          
          "d /data/jellyfin 774 jellyfin media -"
          "d /data/jellyfin/data 774 jellyfin media -"
          "d /data/jellyfin/log 774 jellyfin media -"
          "d /data/jellyfin/config 774 jellyfin media -"
          "d /data/jellyfin/cache 774 jellyfin media -"
        ];

        nixpkgs.config.permittedInsecurePackages = [
          "dotnet-sdk-6.0.428"
          "aspnetcore-runtime-6.0.36"
        ];


        time.timeZone = "America/Denver";
        
        networking = {
          firewall.enable = false;
          useHostResolvConf = lib.mkForce false;
          defaultGateway = "10.0.0.1";
          nameservers = [ "10.0.0.1" ];
        };
    
        services = {
          jellyfin = {
            enable = true;
            openFirewall = true;
            dataDir = "/data/jellyfin/data";
            logDir = "/data/jellyfin/log";
            configDir = "/data/jellyfin/config";
            cacheDir = "/data/jellyfin/cache";
            user = "jellyfin";
            group = "media";
          };

          jackett = {
            enable = true;
            openFirewall = true;
            dataDir = "/data/jackett";
            user = "jackett";
            group = "media";
            port = 9117;
          };

          radarr = {
           enable = true;
           openFirewall = true;
           dataDir = "/data/radarr";
           user = "radarr";
           group = "media";
          };

          sonarr = {
            enable = true;
            openFirewall = true;
            dataDir = "/data/sonarr";
            user = "sonarr";
            group = "media";
          };

          ombi = {
            enable = true;
            openFirewall = true;
            dataDir = "/data/ombi";
            user = "ombi";
            group = "media";
            port = 5000;
          };

          resolved.enable = true;
        };

        system.stateVersion = "24.11";
      };
    };

    containers.torrent = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.0.0.5/24";
      
      bindMounts = {
        "/data" = {
          hostPath = "/home/media/data";
          isReadOnly = false;
        };
        "/media" = {
          hostPath = "/home/media/media";
          isReadOnly = false;
        };
      };

      config = { config, pkgs, lib, ... }:{
        users = {
          users.media = {
            uid = 1000;
            isSystemUser = true;
            description = "media";
            group = "media";
          };
          groups.media = { 
            gid = 1000;
            members = [
              "media"
              "deluge"
            ];
          };
        };
    
        systemd.tmpfiles.rules = [
          "d /data/deluge 774 deluge media -"
          "f /data/deluge/auth 774 deluge media -"
          "d /data/deluge/.config 774 deluge media -"
          "d /data/deluge/.config/deluge 774 deluge media -"
          "f /data/deluge/.config/deluge/core.conf 774 deluge media"
        ];

        time.timeZone = "America/Denver";
        
        networking = {
          firewall.enable = false;
          useHostResolvConf = lib.mkForce false;
          defaultGateway = "10.0.0.1";
          nameservers = [ "10.0.0.1" ];
        };

        services = {
          deluge = {
            enable = true;
            user = "deluge";
            group = "media";
            dataDir = "/data/deluge";
            authFile = "/data/deluge/auth";
            openFirewall = true;
            declarative = true;

            web = {
              enable = true;
              openFirewall = true;
              port = 8080;
            };

            config = {
              download_location = "/media/download/";
              max_upload_speed = "1000.0";
              share_ratio_limit = "1.0";
              allow_remote = false;
              daemon_port = 58846;
              listen_ports = [ 6881 6889 ];
            };
          };

          mullvad-vpn.enable = true;
          resolved.enable = true;
        };
        
        system.stateVersion = "24.11";
      };
    };
  };
}
