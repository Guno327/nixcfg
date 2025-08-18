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
    mineflake.vanilla = {
      enable = true;
      eula = "true";
      serverProperties = {
        gamemode = "creative";
        difficulty = "hard";
        max-players = 5;
        allow-flight = true;
        motd = "Sup Loser";
        force-gamemode = true;
      };
    };
  };
}
