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
  options.srvs.nextcloud.collabora.enable = mkEnableOption "Enable collabora integration";

  config = mkIf cfg.enable {
    # Configure nginx
    services.nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
      forceSSL = true;
      enableACME = true;
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
          inherit (config.services.nextcloud.package.packages.apps) polls richdocuments;
        };

        settings = {
          overwriteprotocol = "https";
        };

        config = {
          adminpassFile = config.sops.secrets."nextcloud".path;
          dbtype = "sqlite";
        };
      };

      # Configure collabora
      collabora-online = mkIf cfg.collabora.enable {
        enable = true;
        port = 9980;
        settings = {
          ssl = {
            enable = false;
            termination = true;
          };

          net = {
            listen = "0.0.0.0";
            post_allow.host = [
              "127.0.0.1"
              "100.100.0.1"
            ];
          };

          storage.wopi = {
            "@allow" = true;
            host = [ "data.ghov.net" ];
          };

          server_name = "collabora.ghov.net";
        };
      };
    };

    services.nginx.virtualHosts."collabora.ghov.net" = mkIf cfg.collabora.enable {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.collabora-online.port}";
        proxyWebsockets = true;
      };
    };

    systemd.services.nextcloud-config-collabora =
      let
        inherit (config.services.nextcloud) occ;

        wopi_url = "http://127.0.0.1:${toString config.services.collabora-online.port}";
        public_wopi_url = "https://collabora.ghov.net";
        wopi_allowlist = lib.concatStringsSep "," [
          "127.0.0.1"
          "100.100.0.1"
        ];
      in
      mkIf cfg.collabora.enable {
        wantedBy = [ "multi-user.target" ];
        after = [
          "nextcloud-setup.service"
          "coolwsd.service"
        ];
        script = ''
          ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
          ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
          ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
          ${occ}/bin/nextcloud-occ richdocuments:setup
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };
  };
}
