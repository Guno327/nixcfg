{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.nginx;
in {
  options.srvs.nginx.enable = mkEnableOption "Enable and configure nginx reverse proxy";
  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@ghov.net";
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = let
        base = locations: {
          inherit locations;

          forceSSL = true;
          enableACME = true;
        };
        proxy = port:
          base {
            "/".proxyPass = "http://127.0.0.1:${toString port}/";
          };
      in {
        "media.ghov.net" = proxy 8096;
        "request.ghov.net" = proxy 5000;
        "sonarr.ghov.net" = proxy 8989;
        "radarr.ghov.net" = proxy 7878;
        "prowlarr.ghov.net" = proxy 9117;
      };
    };
  };
}
