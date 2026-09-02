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

    users = {
      users.actual = {
        uid = 61469;
        name = "actual";
        isSystemUser = true;
        home = "/data/actual";
        group = "actual";
      };
      groups.actual = {
        name = "actual";
        gid = 61469;
      };
    };

    sops.secrets.actual = {
      owner = "actual";
      mode = "0600";
    };

    services.actual = {
      enable = true;
      user = "actual";
      group = "actual";
      settings = {
        dataDir = "/data/actual";
        hostname = "127.0.0.1";
        port = 3000;
        trustedProxies = [ "127.0.0.1/32" ];

        openId = {
          discoveryURL = "https://auth.ghov.net/application/o/actual-budget/.well-known/openid-configuration";
          client_id = "ActualBudget";
          client_secret._secret = config.sops.secrets.actual.path;
          server_hostname = "https://finance.ghov.net";
        };
      };
    };
  };
}
