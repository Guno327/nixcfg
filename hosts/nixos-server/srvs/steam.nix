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
        "/servers" = {
          hostPath = "/home/steam";
          isReadOnly = false;
        };
      };

      config = {
        pkgs,
        lib,
        ...
      }: {
        environment.systemPackages = with pkgs; [
          tmux
          steamcmd
        ];

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
