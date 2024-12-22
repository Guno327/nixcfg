{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.dracula-theme;
in {
  options.features.desktop.dracula-theme.enable =
    mkEnableOption "Theme most apps with dracula theme";

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 14;
      };
      theme = {
        package = pkgs.dracula-theme;
        name = "Dracula";
      };
      iconTheme = {
        package = pkgs.dracula-icon-theme;
        name = "Dracula";
      };
    };

    qt = {
      enable = true;
      style = {
        package = pkgs.dracula-qt5-theme;
        name = "dracula-theme";
      };
    };

    home.file.".config/fcitx5/conf/classicui.conf".text = ''
      Theme=Dracula
      Font="fira-code 14"
    '';
  };

}
