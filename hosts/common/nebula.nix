{ ... }:
{
  services.nebula.networks."mesh" = {
    tun.device = "nebula0";
    staticHostMap."100.100.0.1" = [ "lighthouse.ghov.net:4242" ];
    lighthouses = [ "100.100.0.1" ];
    firewall = {
      inbound = [
        {
          host = "any";
          proto = "any";
          port = "any";
        }
      ];
      outbound = [
        {
          host = "any";
          proto = "any";
          port = "any";
        }
      ];
    };
    settings = {
      firewall.unsafe_routes = [
        {
          route = "0.0.0.0/0";
          via = "100.100.0.1";
        }
      ];
    };
  };
}
