{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.mail;
in {
  options.srvs.mail = {
    enable = mkEnableOption "Enable mail service";
  };

  config = mkIf cfg.enable {
    mailserver = {
      fqdn = "mail.ghov.net";
      domains = ["ghov.net"];
    };
  };
}
