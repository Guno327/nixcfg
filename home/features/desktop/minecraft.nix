{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.minecraft;
in
{
  options.features.desktop.minecraft.enable = mkEnableOption "Install minecraft";

  config = mkIf cfg.enable {
    programs.java = {
      enable = true;
    };

    home.packages = with pkgs; [ stable.prismlauncher ];
  };
}
