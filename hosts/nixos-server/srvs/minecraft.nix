{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.minecraft;
in {
  options.srvs.minecraft = {
    enable = mkEnableOption "Enable steam service";
    type = mkOption {
      type = types.str;
      default = "VANILLA";
      description = "They type of server to enable (VANILLA, AUTO_CURSEFORGE, FTBA)";
    };
    name = mkOption {
      type = types.str;
      default = "server";
      description = "The name you want the server to have";
    };
    id = mkOption {
      type = types.str;
      default = "";
      description = "The ID for the server (For FTB the modpack ID, for Curseforge the modpack page slug (e.g. all-the-mods-8))";
    };
    version = mkOption {
      type = types.str;
      default = "LATEST";
      description = "The minecraft version to use (default latest)";
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.minecraft = {
        uid = 2556;
        name = "minecraft";
        isSystemUser = true;
        home = "/home/minecraft";
        group = "minecraft";
      };
      groups.minecraft = {
        gid = 2556;
        name = "minecraft";
      };
    };
    systemd.tmpfiles.rules = [
      "d /home/minecraft 774 minecraft minecraft -"
    ];

    virtualisation.oci-containers.containers = {
      minecraft = {
        autoStart = true;
        image = "itzg/minecraft-server";
        ports = ["25565:25565"];
        volumes = ["/home/minecraft/${cfg.name}:/data"];
        environment = {
          EULA = "true";
          UID = "2556";
          GID = "2556";
          INIT_MEMORY = "1G";
          MAX_MEMORY = "16G";
          TZ = "America/Denver";
          USE_AIKAR_FLAGS = "true";
          TYPE = cfg.type;
          DIFFICULTY = "hard";
          MAX_PLAYERS = "10";
          ALLOW_FLIGHT = "true";
          USE_SIMD_FLAGS = "true";
          VERSION = cfg.version;
          CF_SLUG = cfg.id;
          FTB_MODPACK_ID = cfg.id;
          CF_API_KEY = "";
        };
      };
    };
  };
}
