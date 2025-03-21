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
      matchBlocks = {
        server = {
          hostname = "10.0.0.3";
          user = "gunnar";
        };
        desktop = {
          hostname = "10.0.0.100";
          user = "gunnar";
        };
      };
    };
  };
}
