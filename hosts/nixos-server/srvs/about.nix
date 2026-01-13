{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.about;
in {
  options.srvs.about.enable = mkEnableOption "Enable systemd services for about website";
  config = mkIf cfg.enable {
    systemd.services.about = {
      enable = true;
      description = "About Website";
      unitConfig = {
        Type = "simple";
      };
      script = ''
        cd /etc/about
        exec ./website
      '';
    };
  };
}
