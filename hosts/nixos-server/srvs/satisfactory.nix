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

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open ports in the firewall for the server
      '';
    };
  };

  config = mkIf cfg.enable {
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

    users.users.satisfactory = {
      description = "Satisfactory server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "satisfactory";
    };
    users.groups.satisfactory = {};

    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [7777 8888];
      allowedTCPPorts = [7777];
    };
  };
}
