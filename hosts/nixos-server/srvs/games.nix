{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.games;
in {
  options.srvs.games = {
    enable = mkEnableOption "Enable games service";
    satisfactory.enable = mkEnableOption "Enable satisfactory server";
    unturned.enable = mkEnableOption "Enable unturned server";
    factorio.enable = mkEnableOption "Enable factorio server";
  };

  config = mkIf cfg.enable {
    users = {
      users.games = {
        uid = 9000;
        name = "games";
        isSystemUser = true;
        home = "/home/games";
        group = "games";
      };
      groups.games = {
        gid = 9000;
        name = "games";
      };
    };
    systemd.tmpfiles.rules = [
      "d /home/games 774 games games -"
    ];

    virtualisation.oci-containers.containers = {
      satisfactory = mkIf cfg.satisfactory.enable {
        autoStart = true;
        image = "wolveix/satisfactory-server:latest";
        ports = ["7777:7777/udp" "7777:7777/tcp"];
        volumes = ["/home/games/satisfactory:/config"];
        environment = {
          MAX_PLAYERS = "4";
          PGID = "9000";
          PUID = "9000";
          STEAMBETA = "false";
        };
      };

      factorio = mkIf cfg.factorio.enable {
        autoStart = true;
        image = "factoriotools/factorio";
        ports = ["34197:34197/udp"];
        volumes = [
          "/home/games/factorio:/factorio"
        ];
        environment = {
          GENERATE_NEW_SAVE = "true";
          PORT = "34197";
          SAVE_NAME = "ghov";
          TOKEN = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/factorio.key);
          UPDATE_MODS_ON_START = "true";
          DLC_SPACE_AGE = "false";
        };
      };
    };
  };
}
