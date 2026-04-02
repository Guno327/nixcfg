{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.adblock;
in
{
  options.srvs.adblock = {
    enable = mkEnableOption "Enable adguardhome service";
  };

  config = mkIf cfg.enable {
    services.traefik.dynamicConfigOptions = mkIf config.srvs.traefik.enable {
      http = {
        routers.ads-router = {
          rule = "Host(`ads.ghov.net`)";
          entryPoints = [ "websecure" ];
          priority = 10;
          service = "ads-service";
        };
        services.ads-service.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:5353";
            preservePath = true;
          }
        ];
      };
    };

    networking.firewall =
      if config.services.nebula.networks."mesh".enable then
        {
          interfaces."nebula0" = {
            allowedTCPPorts = [
              53
              853
            ];
            allowedUDPPorts = [ 53 ];
          };
        }
      else
        {
          allowedTCPPorts = [
            53
            853
          ];
          allowedUDPPorts = [ 53 ];
        };

    services.adguardhome = {
      enable = true;
      mutableSettings = false;
    };
  };
}
