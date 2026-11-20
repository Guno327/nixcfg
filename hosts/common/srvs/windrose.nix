{
  pkgs,
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
      default = "/var/lib/windrose";
    };

    inviteCode = mkOption {
      type = types.str;
      description = "used to connect in game";
    };

    steamLogin = {
      enable = mkEnableOption "authenticated Steam login for server downloads (sops secrets windrose-steam-username / windrose-steam-password)";

      usernameVar = mkOption {
        type = types.str;
        default = "STEAM_USERNAME";
        description = "Env var the image reads the Steam username from";
      };

      passwordVar = mkOption {
        type = types.str;
        default = "STEAM_PASSWORD";
        description = "Env var the image reads the Steam password from";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
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
        extraOptions = [
          "--stop-timeout=30"
          "--network=host"
        ];

        ports = [ "8780:8780" ];

        environment = {
          PUID = "976";
          PGID = "965";

          UPDATE_ON_START = "true";
          SERVER_NAME = "ghov";
          MAX_PLAYERS = "10";
          GENERATE_SETTINGS = "true";
          INVITE_CODE = cfg.inviteCode;
          WINDROSE_PLUS_ENABLED = "true";
          P2P_PROXY_ADDRESS = "192.168.1.3";
        };

        environmentFiles = [ config.sops.secrets.windrose-env.path ];

        volumes = [
          "${cfg.dataDir}/server-files:/home/steam/server-files"
        ];
      };

      systemd = {
        services.restart-podman-windrose = {
          description = "Restart podman-windrose daily";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.systemd}/bin/systemctl restart podman-windrose.service";
          };
        };

        timers.restart-podman-windrose = {
          description = "Timer to restart podman-windrose daily at 3AM";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*-*-* 03:00:00";
            Persistent = true;
            Unit = "restart-podman-windrose.service";
          };
        };
      };
    }

    (mkIf cfg.steamLogin.enable {
      sops.secrets.windrose-steam-username = { };
      sops.secrets.windrose-steam-password = { };

      sops.templates.windrose-steam-env = {
        owner = "windrose";
        mode = "0600";
        content = ''
          ${cfg.steamLogin.usernameVar}=${config.sops.placeholder.windrose-steam-username}
          ${cfg.steamLogin.passwordVar}=${config.sops.placeholder.windrose-steam-password}
        '';
      };

      virtualisation.oci-containers.containers.windrose.environmentFiles = [
        config.sops.templates.windrose-steam-env.path
      ];

      systemd.services.podman-windrose.restartTriggers = [
        config.sops.templates.windrose-steam-env.file
      ];
    })
  ]);
}
