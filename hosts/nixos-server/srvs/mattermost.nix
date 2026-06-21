{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.mattermost;
in
{
  options.srvs.mattermost = {
    enable = mkEnableOption "Enable and configure mattermost";
  };

  config = mkIf cfg.enable {
    services.traefik.dynamicConfigOptions = mkIf config.srvs.traefik.enable {
      http = {
        routers = {
          chat-router = {
            rule = "Host(`chat.ghov.net`)";
            entryPoints = [ "websecure" ];
            priority = 10;
            service = "chat-service";
          };
        };
        services = {
          chat-service.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:8065";
              preservePath = true;
            }
          ];
        };
      };
    };

    services.mattermost = {
      enable = true;
      siteUrl = "https://chat.ghov.net";
      database.peerAuth = true;
    };
  };
}
