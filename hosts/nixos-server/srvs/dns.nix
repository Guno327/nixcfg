{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.dns;
in
{
  options.srvs.dns = {
    enable = mkEnableOption "Enable blocky";
  };

  config = mkIf cfg.enable {
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

    services = {
      blocky = {
        enable = true;

        settings = {
          ede.enable = true;

          ports = {
            dns = "100.100.0.2:53";
            tls = "100.100.0.2:853";
          };

          certFile = "/var/lib/acme/ghov.net/fullchain.pem";
          keyFile = "/var/lib/acme/ghov.net/key.pem";

          upstreams = {
            init.strategy = "fast";
            groups.default = [
              "tcp-tls:dns.quad9.net:853"
              "tcp-tls:dns.mullvad.net:853"
            ];
            strategy = "parallel_best";
            timeout = "2s";
          };

          bootstrapDns = [
            {
              upstream = "tcp-tls:dns.quad9.net:853";
              ips = [
                "9.9.9.9"
                "149.112.112.112"
              ];
            }
            {
              upstream = "tcp-tls:dns.mullvad.net:853";
              ips = [ "194.242.2.2" ];
            }
          ];

          blocking = {
            denylists.ads = [
              "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.plus.txt"
            ];
            clientGroupsBlock.default = [ "ads" ];
          };

          caching = {
            minTime = "5m";
            maxTime = "24h";
            prefetching = true;
            cacheTimeNegative = "1m";
          };
        };
      };
    };
    systemd.services.blocky.serviceConfig.SupplementaryGroups = [ "traefik" ];
  };
}
