{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.finance;
in
{
  options.srvs.finance = {
    enable = mkEnableOption "finance budgeting software";
  };

  config = mkIf cfg.enable {
    services.traefik.dynamicConfigOptions = mkIf config.srvs.traefik.enable {
      http = {
        routers.finance-router = {
          rule = "Host(`finance.ghov.net`)";
          entryPoints = [ "websecure" ];
          priority = 10;
          service = "finance-service";
        };
        services.finance-service.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:3000";
            preservePath = true;
          }
        ];
      };
    };

    services.actual = {
      enable = true;
      settings = {
        dataDir = "/data/actual";
        hostname = "127.0.0.1";
        port = 3000;
      };
    };
  };
}
