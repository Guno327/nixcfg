{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.cli.ssh;
in
{
  options.features.cli.ssh.enable = mkEnableOption "Enable and configure ssh";
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
  };
}
