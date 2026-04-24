{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.windrose;
in
{
  options.srvs.windrose = {
    enable = mkEnableOption "windrose Dedicated Server";

    dataDir = mkOption {
      type = types.path;
      description = "Directory to store game server";
      default = "/data/windrose";
    };

    inviteCode = mkOption {
      type = types.str;
      description = "used to connect in game";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.windrose-env = {
      owner = "windrose";
      mode = "0600";
    };

    users.groups.windrose = {
      gid = 965;
    };
    users.users.windrose = {
      isSystemUser = true;
      uid = 976;
      group = "windrose";
      home = cfg.dataDir;
    };

    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers.windrose = {
      image = "indifferentbroccoli/windrose-server-docker:latest";
      autoStart = true;
      extraOptions = [ "--stop-timeout=30" ];

      environment = {
        PUID = "976";
        PGID = "965";

        UPDATE_ON_START = "true";
        SERVER_NAME = "ghov";
        MAX_PLAYERS = "10";
        GENERATE_SETTINGS = "true";
        INVITE_CODE = cfg.inviteCode;
      };

      environmentFiles = [ config.sops.secrets.windrose-env.path ];

      volumes = [
        "${cfg.dataDir}/server-files:/home/steam/server-files"
      ];
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };

}
