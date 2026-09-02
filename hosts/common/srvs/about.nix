{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.about;
in
{
  options.srvs.about.enable = mkEnableOption "Enable systemd services for about website";
  config = mkIf cfg.enable {
    services.traefik.dynamicConfigOptions = mkIf config.srvs.traefik.enable {
      http = {
        routers.about-router = {
          rule = "Host(`about.ghov.net`)";
          entryPoints = [ "websecure" ];
          priority = 10;
          service = "about-service";
        };
        services.about-service.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:8096";
            preservePath = true;
          }
        ];
      };
    };

    systemd.services.about = {
      enable = true;
      description = "About Website";
      unitConfig = {
        Type = "simple";
      };
      script = ''
        cd /etc/about
        exec ./website
      '';
    };
  };
}
