{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.pufferpanel;
in {
  options.srvs.pufferpanel.enable = mkEnableOption "Enable minecraft container";

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /home/pufferpanel 774 gunnar users -"
      "d /home/pufferpanel/servers 774 gunnar users -"
      "d /home/pufferpanel/logs 774 gunnar users -"
    ];

    containers.pufferpanel = {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "10.0.0.6/24";

      bindMounts = {
        "/var/lib/pufferpanel/servers" = {
          hostPath = "/home/pufferpanel";
          isReadOnly = false;
        };
      };

      config = {
        pkgs,
        lib,
        ...
      }: {
        services.pufferpanel = {
          enable = true;
          environment = {
            PUFFER_PANEL_ENABLE = "true";
            PUFFER_PANEL_REGISTRATIONENABLED = "false";
            PUFFER_WEB_HOST = ":8080";
          };
        };

        nixpkgs.config.allowUnfree = true;
        environment.systemPackages = with pkgs; [
          jdk21
          jdk17
          jdk8
          pufferpanel
          steamcmd
        ];

        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
          jdk21
          jdk17
          jdk8
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
          nameservers = ["10.0.0.1"];
        };

        services.resolved.enable = true;
        system.stateVersion = "24.11";
      };
    };
  };
}
