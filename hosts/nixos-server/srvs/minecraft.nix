{ config, lib, ... }:
with lib;
let
  cfg = config.srvs.minecraft;
in
{
  options.srvs.minecraft.enable = mkEnableOption "Enable minecraft container";

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
      localAddress = "10.0.0.6/24";

      bindMounts = {
        "/var/lib/pufferpanel/servers" = {
          hostPath = "/home/minecraft";
          isReadOnly = false;
        };
      };

      config =
        { pkgs, lib, ... }:
        {
          services.pufferpanel = {
            enable = true;
            environment = {
              PUFFER_PANEL_ENABLE = "true";
              PUFFER_PANEL_REGISTRATIONENABLED = "false";
              PUFFER_WEB_HOST = ":8080";
            };
          };

          environment.systemPackages = with pkgs; [
            jdk21
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
            defaultGateway = "10.0.0.1";
            nameservers = [ "10.0.0.1" ];
          };

          services.resolved.enable = true;
          system.stateVersion = "24.11";
        };
    };
  };
}
