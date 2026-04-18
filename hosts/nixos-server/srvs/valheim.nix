{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.valheim;
in
{
  options.srvs.valheim = {
    enable = mkEnableOption "valheim Dedicated Server";

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
      default = "/var/lib/valheim";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall =
      if config.services.nebula.networks."mesh".enable then
        {
          interfaces."nebula0" = {
            allowedUDPPorts = [
              2456
              2457
            ];
          };
        }
      else
        {
          allowedUDPPorts = [
            2456
            2457
          ];
        };

    users.users.valheim = {
      description = "valheim server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "valheim";
    };
    users.groups.valheim = { };

    sops.secrets.valheim = {
      owner = "valheim";
      mode = "0600";
    };

    systemd.services.valheim =
      let
        steamcmd = "${cfg.steamcmdPackage}/bin/steamcmd";
        steam-run = "${pkgs.steam-run}/bin/steam-run";
      in
      {
        description = "valheim Dedicated Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          TimeoutSec = "15min";
          Restart = "always";
          User = "valheim";
          WorkingDirectory = cfg.dataDir;
        };

        preStart = ''
          ${steamcmd} +force_install_dir "${cfg.dataDir}" +login anonymous +app_update 896660 -beta public validate +quit
        '';

        script = ''
          #! /usr/bin/env bash
          export templdpath=$LD_LIBRARY_PATH  
          export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH  
          export SteamAppID=892970
          export VALHEIM_PASSWD=$(cat /run/secrets/valheim)

          echo "Starting server PRESS CTRL-C to exit"  
          ${steam-run} /var/lib/valheim/valheim_server.x86_64 -name "scrungus" -port 2456 -nographics -batchmode -world "scrungus" -password "$VALHEIM_PASSWD" -public 1  
          export LD_LIBRARY_PATH=$templdpath
        '';
      };
  };
}
