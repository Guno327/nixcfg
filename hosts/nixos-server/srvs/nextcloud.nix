{
  config,
  lib,
  pkgs,
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
      package = pkgs.nextcloud32;
      datadir = "/storage/nextcloud";
      hostName = "data";
      config = {
        adminpassFile = config.sops.secrets.nextcloud.path;
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
