{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.vanillaplusplus;
in
{
  options.srvs.vanillaplusplus = {
    enable = mkEnableOption "vanillaplusplus Dedicated Server";
  };

  config = mkIf cfg.enable {
    networking.firewall =
      if config.services.nebula.networks."mesh".enable then
        {
          interfaces."nebula0" = {
            allowedUDPPorts = [
              25565
            ];
          };
        }
      else
        {
          allowedUDPPorts = [
            25565
          ];
        };

    services.vanillaplusplus = {
      enable = true;
      eula = true;
      serverProperties = {
        motd = "Vanilla++";
        max-players = "10";
        allow-flight = true;

      };
    };

  };
}
