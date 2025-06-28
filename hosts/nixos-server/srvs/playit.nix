{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.playit;
in {
  options.srvs.playit.enable = mkEnableOption "Enable playit tunnel";
  config = mkIf cfg.enable {
    environment.etc."playit.toml" = {
      text = builtins.readFile ../../../secrets/playit.toml;
    };

    services.playit = {
      enable = true;
      user = "playit";
      group = "playit";
      secretPath = "/etc/playit.toml";
    };
  };
}
