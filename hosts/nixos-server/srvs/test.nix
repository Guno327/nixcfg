{ config, lib, ... }: with lib;
let 
  cfg = config.srvs.test;
in {
  options.srvs.test.enable = mkEnableOption "Enable test container";
  config = mkIf cfg.enable {
    containers.test = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "192.168.122.88/24";
      
      bindMounts = {
        "/var/www/site" = {
          hostPath = "/home/test";
          isReadOnly = false;
        };
      };

      config = { lib, ... }:{
        services.static-web-server = {
          enable = true;
          root = "/var/www/site";
        };
        
        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [ 8787 ];
          };
          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;
        system.stateVersion = "24.11";
      };
    };
  };
}
