{ config, lib, ... }:
with lib;
let
  cfg = config.features.cli.zoxide;
in
{
  options.features.cli.zoxide.enable = mkEnableOption "Enable and alias zoxide";

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.fish.shellAbbrs = {
      cd = "z";
    };
  };
}
