{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.minecraft;
in {
  options.features.desktop.minecraft.enable =
    mkEnableOption "install additional fonts for dekstop apps";

  config = mkIf cfg.enable {
    programs.java = {
      enable = true;
    };

    home.packages = with pkgs; [
      prismlauncher
    ];

  };
}
