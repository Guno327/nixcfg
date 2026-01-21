{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.alacritty;
in {
  options.features.desktop.alacritty.enable = mkEnableOption "Configure alacritty";
  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      theme = "catppuccin_mocha";
    };
  };
}
