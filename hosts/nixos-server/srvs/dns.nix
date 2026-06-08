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
    enable = mkEnableOption "Enable adguardhome + unbound services";
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
      unbound = {
        enable = true;
        resolveLocalQueries = false;
        settings.server = {
          interface = [ "127.0.0.1" ];
          port = 5335;
          access-control = [ "127.0.0.1/32 allow" ];

          qname-minimisation = true;
          harden-glue = true;
          harden-dnssec-stripped = true;
          hide-identity = true;
          hide-version = true;

          prefetch = true;
          prefetch-key = true;
          cache-min-ttl = 300;
          cache-max-ttl = 86400;
          msg-cache-size = "128m";
          rrset-cache-size = "256m";

          edns-buffer-size = 1232;
        };
      };

      blocky = {
        enable = true;
        settings = {
          ports = {
            dns = "100.100.0.2:53";
            tls = "100.100.0.2:853";
          };

          certFile = "/var/lib/acme/ghov.net/fullchain.pem";
          keyFile = "/var/lib/acme/ghov.net/key.pem";

          upstreams = {
            groups.default = [ "127.0.0.1:5335" ];
            strategy = "strict";
          };

          blocking = {
            denylists.ads = [
              "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt"
            ];
            clientGroupsBlock.default = [ "ads" ];
          };

          caching = {
            minTime = "5m";
            maxTime = "30m";
            prefetching = true;
          };
        };
      };
    };
    systemd.services.blocky.serviceConfig.SupplementaryGroups = [ "traefik" ];
  };
}
