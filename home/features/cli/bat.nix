{ config, lib, ... }:
with lib;
let
  cfg = config.features.cli.bat;
in
{
  options.features.cli.bat.enable = mkEnableOption "Enable and configure bat";
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
    };
  };
}
