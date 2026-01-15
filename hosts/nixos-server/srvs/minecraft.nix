{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.minecraft;
in {
  options.srvs.minecraft = {
    enable = mkEnableOption "Enable minecraft service";
  };

  config = mkIf cfg.enable {
    # Open Firewall
    networking.firewall =
      if config.services.nebula.networks."mesh".enable
      then {
        interfaces."nebula0" = {
          allowedTCPPorts = [25565];
          allowedUDPPorts = [25565];
        };
      }
      else {
        allowedTCPPorts = [25565];
        allowedUDPPorts = [25565];
      };

    services.flakecraft = {
      enable = true;
      name = "test";
      environment = {
        EULA = "TRUE";
      };
    };
  };
}
