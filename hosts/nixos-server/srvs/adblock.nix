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
            ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" "https://easylist.to/easylist/easylist.txt"];
            cookies = ["https://secure.fanboy.co.nz/fanboy-annoyance.txt"];
            privacy = ["https://easylist.to/easylist/easyprivacy.txt"];
          };
          clientGroupsBlock = {
            default = ["ads" "cookies" "privacy"];
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
