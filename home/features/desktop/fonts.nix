{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.fonts;
in
{
  options.features.desktop.fonts.enable = mkEnableOption "install additional fonts for dekstop apps";

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      fira-code
      fira-code-symbols
      fira-code-nerdfont
      font-manager
      font-awesome_5
      noto-fonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
    ];
  };
}
