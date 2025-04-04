{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.steam;
in {
  options.srvs.steam = {
    enable = mkEnableOption "Enable steam service";
    satisfactory.enable = mkEnableOption "Enable satisfactory server";
    unturned.enable = mkEnableOption "Enable unturned server";
  };

  config = mkIf cfg.enable {
    users = {
      users.steam = {
        uid = 9000;
        name = "steam";
        isSystemUser = true;
        home = "/home/steam";
        group = "steam";
      };
      groups.steam = {
        gid = 9000;
        name = "steam";
      };
    };
    systemd.tmpfiles.rules = [
      "d /home/steam 774 steam steam -"
    ];

    virtualisation.oci-containers.containers = {
      satisfactory = mkIf cfg.satisfactory.enable {
        autoStart = true;
        image = "wolveix/satisfactory-server:latest";
        ports = ["7777:7777/udp" "7777:7777/tcp"];
        volumes = ["/home/steam/satisfactory:/config"];
        environment = {
          MAX_PLAYERS = "4";
          PGID = "9000";
          PUID = "9000";
          STEAMBETA = "false";
        };
      };
    };
  };
}
