{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.authentik;
in
{
  options.srvs.authentik.enable = mkEnableOption "Enable and configure authentik";
  config = mkIf cfg.enable {
    services.authentik = {
      enable = true;
      environmentFile = config.sops.secrets.authentik.path;
      settings = {
        disable_startup_analytics = true;
        error_reporting.enable = false;
      };
    };
  };
}
