{ config, lib, ... }: with lib;
let 
  cfg = config.srvs.site;
in {
  options.srvs.site.enable = mkEnableOption "Enable website container";
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /home/site 775 gunnar users -"
    ];

    containers.site = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "192.168.122.92/24";
      
      bindMounts = {
        "/site" = {
          hostPath = "/home/site";
          isReadOnly = false;
        };
      };

      config = { config, pkgs, lib, ... }:{
        users.users.nginx = {
          isSystemUser = true;
          group = "nginx";
        };
        users.groups.nginx = {};

        systemd.tmpfiles.rules = [
          "f /site/index.html 775 static-web-server static-web-server -"
        ];

        services.static-web-server = {
          enable = true;
          root = "/site";
          listen = "[::]:80";
        };

        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [ 80 ];
          };
          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;
        system.stateVersion = "24.11";
      };
    };
  };
}
