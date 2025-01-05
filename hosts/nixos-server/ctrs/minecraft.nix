{ config, lib, ... }: with lib;
let 
  cfg = config.ctrs.minecraft;
in {
  options.ctrs.minecraft.enable = mkEnableOption "Enable minecraft container";
  
  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /home/minecraft 774 gunnar users -"
      "d /home/minecraft/servers 774 gunnar users -"
      "d /home/minecraft/logs 774 gunnar users -"
    ];

    containers.minecraft = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "192.168.122.91/24";
      
      bindMounts = {
        "/var/lib/pufferpanel/servers" = {
          hostPath = "/home/minecraft";
          isReadOnly = false;
        };
      };

      config = { config, pkgs, lib, ... }:{
        services.pufferpanel = {
          enable = true;
          environment = {
            PUFFER_PANEL_ENABLE = "true";
            PUFFER_PANEL_REGISTRATIONENABLED = "false";
            PUFFER_WEB_HOST = ":8080";
          };
        };
  
        environment.systemPackages = with pkgs; [
          jdk17
          jdk8
          pufferpanel
        ];

        environment.etc."/scripts/pufferpanel_user.sh" = {
          text = ''
            #!/bin/sh
            pufferpanel --workDir /var/lib/pufferpanel user add --admin
          '';
          mode = "110";
        };

        networking = {
          firewall.enable = false;
          useHostResolvConf = lib.mkForce false;
          defaultGateway = "192.168.122.1";
          nameservers = [ "192.168.122.1" ];
        };

        services.resolved.enable = true;
        system.stateVersion = "24.11";
      };
    };
  };
}
