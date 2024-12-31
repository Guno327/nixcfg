{ config, lib, ... }: with lib;
let
  cfg = config.features.desktop.kitty;
in {
  options.features.desktop.kitty.enable =
    mkEnableOption "Configure kitty";

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font.name = "fira-code";
      font.size = 14;
      shellIntegration.enableFishIntegration = true;
      shellIntegration.enableBashIntegration = true;
    };
  };
}
