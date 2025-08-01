{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.minecraft;
in {
  options.srvs.minecraft = {
    enable = mkEnableOption "Enable minecraft service";
  };

  config = mkIf cfg.enable {
    mineflake.vanilla = {
      enable = true;
    };
  };
}
