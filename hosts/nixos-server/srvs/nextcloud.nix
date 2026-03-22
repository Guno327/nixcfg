{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.nextcloud;
in
{
  options.srvs.nextcloud.enable = mkEnableOption "Enable and configure nextcloud";
  options.srvs.nextcloud.onlyoffice.enable = mkEnableOption "Enable onlyoffice integration";

  config = mkIf cfg.enable {
    sops.secrets = {
      nextcloud = {
        owner = "onlyoffice";
        mode = "0600";
      };

      onlyoffice-nonce = {
        owner = "nginx";
        group = "onlyoffice";
        mode = "0660";
      };
    };

    services = {
      # Configure nextcloud
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud33;
        hostName = "data.ghov.net";
        home = "/data/nextcloud";
        database.createLocally = true;

        extraAppsEnable = true;
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps) polls onlyoffice;
        };

        settings = {
          overwriteprotocol = "https";
        };

        config = {
          adminpassFile = config.sops.secrets."nextcloud".path;
          dbtype = "sqlite";
        };
      };

      onlyoffice = mkIf cfg.onlyoffice.enable {
        enable = true;
        hostname = "office.ghov.net";
        port = 8458;
        securityNonceFile = config.sops.secrets.onlyoffice-nonce.path;
        jwtSecretFile = config.sops.secrets.nextcloud.path;
      };
      epmd.listenStream = mkIf cfg.onlyoffice.enable ("0.0.0.0:4369");
    };
  };
}
