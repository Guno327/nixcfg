{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.nextcloud;
in {
  options.srvs.nextcloud = {
    enable = mkEnableOption "Enable nextcloud service";
  };

  config = mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      hostName = "data";
      config = {
        adminpassFile = "/flake/secrets/nextcloud.pass";
        dbtype = "sqlite";
      };
      settings = {
        trusted_domains = [
          "nixos-server"
          "data.ghov.net"
        ];
      };
    };
  };
}
