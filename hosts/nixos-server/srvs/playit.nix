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
    services.playit = {
      enable = true;
      user = "playit";
      group = "playit";
      secretPath = config.sops.secrets.playit.path;
    };
  };
}
