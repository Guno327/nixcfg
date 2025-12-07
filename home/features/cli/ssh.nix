{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.ssh;
in {
  options.features.cli.ssh.enable = mkEnableOption "Enable and configure ssh";
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "vps" = {
          host = "vps";
          hostname = "192.168.100.1";
        };
        "server" = {
          host = "server";
          hostname = "192.168.100.3";
        };
        "laptop" = {
          host = "laptop";
          hostname = "192.168.100.9";
        };
      };
    };
  };
}
