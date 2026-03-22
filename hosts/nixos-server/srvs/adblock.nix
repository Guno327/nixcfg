{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.adblock;
in
{
  options.srvs.adblock = {
    enable = mkEnableOption "Enable adguardhome service";
  };

  config = mkIf cfg.enable {
    # Open Firewall
    networking.firewall =
      if config.services.nebula.networks."mesh".enable then
        {
          interfaces."nebula0" = {
            allowedTCPPorts = [
              53
              853
            ];
            allowedUDPPorts = [
              53
              853
            ];
          };
        }
      else
        {
          allowedTCPPorts = [
            53
            853
          ];
          allowedUDPPorts = [
            53
            853
          ];
        };

    services.adguardhome = {
      enable = true;
      mutableSettings = false;
    };
  };
}
