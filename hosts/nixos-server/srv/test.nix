{ config, lib, ... }: with lib;
let 
  cfg = config.srv.test;
in {
  options.srv.test.enable = mkEnableOption "Enable test service";
  config = mkIf cfg.enable {
    containers.test = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.122.86";
      localAddress = "192.168.122.87";
      
      bindMounts = {
        "/var/www/site" = {
          hostPath = "/home/test";
          isReadOnly = false;
        };
      };

      config = { config, pkgs, lib, ... }:{
        services.static-web-server = {
          enable = true;
          root = "/var/www/site";
        };
        
        networking = {
          firewall.allowedTCPPorts = [ 8787 ];
          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;
        system.stateVersion = "24.11";
      };
    };
  };
}
