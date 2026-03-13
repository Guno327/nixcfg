{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.nginx;
in
{
  options.srvs.nginx.enable = mkEnableOption "Enable and configure nginx reverse proxy";
  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@ghov.net";
      certs."ghov.net" = {
        domain = "ghov.net";
        extraDomainNames = [ "*.ghov.net" ];
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets.dns-01.path;
        group = "nginx";
      };
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts =
        let
          base = locations: {
            inherit locations;

            forceSSL = true;
            addSSL = false;
            useACMEHost = "ghov.net";

            listen = [
              {
                addr = "127.0.0.1";
                port = 8443;
                ssl = true;
                proxyProtocol = true;
              }
            ];
          };
          proxy =
            port:
            base {
              "/".proxyPass = "http://127.0.0.1:${toString port}/";
            };
          proxyWebsockets =
            port:
            base {
              "/" = {
                proxyPass = "http://127.0.0.1:${toString port}/";
                proxyWebSockets = true;
              };
            };
        in
        {
          "about.ghov.net" = proxy 81;
          "media.ghov.net" = mkIf config.srvs.media.enable (proxy 8096);
          "request.ghov.net" = mkIf config.srvs.media.enable (proxy 5000);
          "sonarr.ghov.net" = mkIf config.srvs.media.enable (proxy 8989);
          "radarr.ghov.net" = mkIf config.srvs.media.enable (proxy 7878);
          "prowlarr.ghov.net" = mkIf config.srvs.media.enable (proxy 9117);
          "factory.ghov.net" = mkIf config.srvs.satisfactory.enable (proxy 9090);
          "ads.ghov.net" = mkIf config.srvs.adblock.enable (proxy 5353);

          "data.ghov.net" = mkIf config.srvs.nextcloud.enable (base { });
          "collabora.ghov.net" = mkIf config.srvs.nextcloud.collabora.enable (
            proxyWebsockets config.services.collabora-online.port
          );
          "auth.ghov.net" = mkIf config.srvs.authentik.enable (proxyWebsockets 9000);
        };

      streamConfig = ''
        map $ssl_preread_server_name $backend_target {
          hostnames;
          landscape.ghov.net  10.1.1.21:443;
          default             127.0.0.1:8444;
        }

        server {
          listen 443;
          proxy_pass $backend_target;
          ssl_preread on;
        }

        server {
          listen 127.0.0.1:8444;
          proxy_pass 127.0.0.1:8443;
          proxy_protocol on; 
        }
      '';
    };
  };
}
