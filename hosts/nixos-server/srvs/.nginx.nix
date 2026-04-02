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
            useACMEHost = "ghov.net";

            listen = [
              {
                addr = "100.100.0.2";
                port = 443;
                ssl = true;
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
                proxyWebsockets = true;
              };
            };
        in
        {
          "fallback" = mkMerge [
            (base { })
            ({
              serverName = "_";
              default = true;
              extraConfig = ''
                keepalive_timeout 0;
                error_page 404 /index.html;
                location = /index.html {
                  internal;
                  # This is a 'here-doc' style way to write a quick HTML page
                  return 200 "<html><body><h1>SNI Match Failed</h1><p>The domain you requested is not configured on this proxy.</p></body></html>";
                  add_header Content-Type text/html;
                }
              '';
            })
          ];

          "about.ghov.net" = proxy 81;
          "media.ghov.net" = mkIf config.srvs.media.enable (proxy 8096);
          "request.ghov.net" = mkIf config.srvs.media.enable (proxy 5000);
          "sonarr.ghov.net" = mkIf config.srvs.media.enable (proxy 8989);
          "radarr.ghov.net" = mkIf config.srvs.media.enable (proxy 7878);
          "prowlarr.ghov.net" = mkIf config.srvs.media.enable (proxy 9117);
          "factory.ghov.net" = mkIf config.srvs.satisfactory.enable (proxy 9090);
          "ads.ghov.net" = mkIf config.srvs.adblock.enable (proxy 5353);

          "data.ghov.net" = mkIf config.srvs.nextcloud.enable (base { });
          "auth.ghov.net" = mkIf config.srvs.authentik.enable (proxyWebsockets 9000);
        };
    };
  };
}
