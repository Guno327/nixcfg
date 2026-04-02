{ config, lib, ... }:
with lib;
let
  cfg = config.srvs.traefik;
in
{
  options.srvs.traefik.enable = mkEnableOption "Enable and configure Traefik reverse proxy";

  config = mkIf cfg.enable {
    networking.firewall =
      if config.services.nebula.networks."mesh".enable then
        {
          interfaces."nebula0" = {
            allowedTCPPorts = [ 443 ];
          };
        }
      else
        {
          allowedTCPPorts = [ 443 ];
        };

    sops.secrets = {
      dns-01 = {
        owner = "acme";
        mode = "0600";
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@ghov.net";
      certs."ghov.net" = {
        domain = "ghov.net";
        extraDomainNames = [ "*.ghov.net" ];
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets.dns-01.path;
        group = "traefik";
      };
    };

    services.traefik = {
      enable = true;

      staticConfigOptions = {
        entryPoints = {
          websecure = {
            address = ":443";
            asDefault = true;
            http.tls = { };
            forwardedHeaders.trustedIPs = [
              "127.0.0.1"
              "100.100.0.1"
            ];
          };
        };
      };

      dynamicConfigOptions = {
        tls.stores.default.defaultCertificate = {
          certFile = "/var/lib/acme/ghov.net/fullchain.pem";
          keyFile = "/var/lib/acme/ghov.net/key.pem";
        };
        certificates = [
          {
            certFile = "/var/lib/acme/ghov.net/fullchain.pem";
            keyFile = "/var/lib/acme/ghov.net/key.pem";
            stores = [ "default" ];
          }
        ];
      };
    };
  };
}
