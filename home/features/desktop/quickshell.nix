{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.quickshell;
in {
  options.features.desktop.quickshell = {
    enable = mkEnableOption "enable config for quickshell";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      })
  ];
}
