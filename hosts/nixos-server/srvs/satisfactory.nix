{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.srvs.satisfactory;
in {
  options.srvs.satisfactory = {
    enable = mkEnableOption "Satisfactory Dedicated Server";

    steamcmdPackage = mkOption {
      type = types.package;
      default = pkgs.steamcmd;
      defaultText = "pkgs.steamcmd";
      description = ''
        The package implementing SteamCMD
      '';
    };

    dataDir = mkOption {
      type = types.path;
      description = "Directory to store game server";
      default = "/var/lib/satisfactory";
    };

    launchOptions = mkOption {
      type = types.str;
      description = "Launch options to use.";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    # Open Firewall
    networking.firewall =
      if config.services.nebula.networks."mesh".enable
      then {
        interfaces."nebula0" = {
          allowedTCPPorts = [7777 8888];
          allowedUDPPorts = [7777];
        };
      }
      else {
        allowedTCPPorts = [7777 8888];
        allowedUDPPorts = [7777];
      };

    # Setup user
    users.users.satisfactory = {
      description = "Satisfactory server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "satisfactory";
    };
    users.groups.satisfactory = {};

    # Configure service
    systemd.services.satisfactory = let
      steamcmd = "${cfg.steamcmdPackage}/bin/steamcmd";
      steam-run = "${pkgs.steam-run}/bin/steam-run";
    in {
      description = "Satisfactory Dedicated Server";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        TimeoutSec = "15min";
        ExecStart = "${steam-run} ${cfg.dataDir}/FactoryServer.sh ${cfg.launchOptions}";
        Restart = "always";
        User = "satisfactory";
        WorkingDirectory = cfg.dataDir;
      };

      preStart = ''
        ${steamcmd} +force_install_dir "${cfg.dataDir}" +login anonymous +app_update 1690800 validate +quit
      '';
    };
  };
}
