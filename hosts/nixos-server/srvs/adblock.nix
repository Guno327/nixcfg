{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.adblock;
in {
  options.srvs.adblock = {
    enable = mkEnableOption "Enable blocky service";
  };

  config = mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
        ports.dns = 53;
        ports.http = 4000;
        upstreams.groups.default = [
          "https://one.one.one.one/dns-query"
        ];
        bootstrapDns = {
          upstream = "https://one.one.one.one/dns-query";
          ips = ["1.1.1.1" "1.0.0.1"];
        };
        blocking = {
          blackLists = {
            ads = ["https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"];
          };
          clientGroupsBlock = {
            default = ["ads"];
          };
        };
        caching = {
          minTime = "5m";
          maxTime = "30m";
          prefetching = true;
        };
      };
    };
  };
}
