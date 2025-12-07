{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.srvs.lighthouse;
in {
  options.srvs.lighthouse.enable = mkEnableOption "Enable this as a nebula lighthouse";
  config = mkIf cfg.enable {
    sops.secrets = {
      "nebula/beacon.crt" = {owner = "nebula-mesh";};
      "nebula/beacon.key" = {owner = "nebula-mesh";};
      "nebula/ca.crt" = {owner = "nebula-mesh";};
    };

    environment.systemPackages = with pkgs; [nebula];
    services.nebula.networks.mesh = {
      enable = true;
      isLighthouse = true;
      cert = config.sops.secrets."nebula/beacon.crt".path;
      key = config.sops.secrets."nebula/beacon.key".path;
      ca = config.sops.secrets."nebula/ca.crt".path;
      listen = {
        host = "0.0.0.0";
        port = 4242;
      };
      firewall = {
        outbound = [
          {
            port = "any";
            proto = "icmp";
            host = "any";
          }
        ];
        inbound = [
          {
            port = "22";
            proto = "tcp";
            groups = ["admins"];
          }
        ];
      };
    };
  };
}
