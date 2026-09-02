{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.authentik;
in
{
  options.srvs.authentik.enable = mkEnableOption "Enable and configure authentik";
  config = mkIf cfg.enable {
    services.traefik.dynamicConfigOptions = mkIf config.srvs.traefik.enable {
      http = {
        routers.auth-router = {
          rule = "Host(`auth.ghov.net`)";
          entryPoints = [ "websecure" ];
          priority = 10;
          service = "auth-service";
        };
        services.auth-service.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:9000";
            preservePath = true;
          }
        ];
      };
    };

    sops.secrets = {
      authentik = {
      };
      authentik-ldap = {
      };
    };

    networking.firewall =
      if config.services.nebula.networks."mesh".enable then
        {
          interfaces."nebula0" = {
            allowedTCPPorts = [
              636
            ];
            allowedUDPPorts = [
              636
            ];
          };
        }
      else
        {
          allowedTCPPorts = [
            636
          ];
          allowedUDPPorts = [
            636
          ];
        };

    services = {
      authentik = {
        enable = true;
        environmentFile = config.sops.secrets.authentik.path;
        settings = {
          disable_startup_analytics = true;
          error_reporting.enable = false;
        };
      };
      authentik-ldap = {
        enable = true;
        environmentFile = config.sops.secrets.authentik-ldap.path;
      };
    };

    systemd.services.authentik-ldap.serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      BindReadOnlyPaths = [ "/var/lib/acme/ghov.net" ];
      User = "authenik";
      Group = "authentik";
    };
  };
}
