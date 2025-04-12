{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.pihole;
in {
  options.srvs.pihole = {
    enable = mkEnableOption "Enable pihole service";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      pihole = {
        autoStart = true;
        image = "pihole/pihole:latest";
        ports = ["53:53/udp" "53:53/tcp" "8888:80/tcp" "442:443/tcp"];
        volumes = ["/home/pihole:/etc/pihole"];
        environment = {
          TZ = "America/Denver";
          FTLCONF_dns_listeningMode = "all";
          FTLCONF_webserver_api_password = "";
        };
      };
    };
  };
}
