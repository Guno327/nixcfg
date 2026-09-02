{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.palworld;
in
{
  options.srvs.palworld = {
    enable = mkEnableOption "palworld Dedicated Server";

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
      default = "/var/lib/palworld";
    };

    launchOptions = mkOption {
      type = types.str;
      description = "Launch options to use.";
      default = "";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall =
      if config.services.nebula.networks."mesh".enable then
        {
          interfaces."nebula0" = {
            allowedUDPPorts = [ 8211 ];
          };
        }
      else
        {
          allowedUDPPorts = [ 8211 ];
        };

    users.users.palworld = {
      description = "palworld server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "palworld";
    };
    users.groups.palworld = { };

    systemd.services.palworld =
      let
        steamcmd = "${cfg.steamcmdPackage}/bin/steamcmd";
        steam-run = "${pkgs.steam-run}/bin/steam-run";
      in
      {
        description = "palworld Dedicated Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          TimeoutSec = "15min";
          ExecStart = "${steam-run} ${cfg.dataDir}/PalServer.sh ${cfg.launchOptions}";
          Restart = "always";
          User = "palworld";
          WorkingDirectory = cfg.dataDir;
        };

        preStart = ''
          ${steamcmd} +force_install_dir "${cfg.dataDir}" +login anonymous +app_update 2394010 validate +quit
        '';
      };
  };
}
