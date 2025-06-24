{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.cloudflared;
in {
  options.srvs.cloudflared.enable = mkEnableOption "Enable cloudflared tunnel";
  config = mkIf cfg.enable {
    services.cloudflared = {
      enable = true;
      tunnels.nixos-server = {
        credentialsFile = "/home/gunnar/.nixcfg/secrets/tunnel.json";
        default = "http_status:404";
      };
    };
  };
}
