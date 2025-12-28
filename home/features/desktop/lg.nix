{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.lg;
in {
  options.features.desktop.lg.enable = mkEnableOption "enable extended looking-glass configuration";
  config = mkIf cfg.enable {
    programs.looking-glass-client = {
      enable = true;
      settings = {
        app = {
          allowDMA = true;
          shmFile = "/dev/kvmfr0";
        };

        win = {
          fullScreen = true;
          showFPS = false;
          jitRender = true;
        };

        spice = {
          enable = true;
          audio = true;
        };

        input = {
          rawMouse = true;
          escapeKey = 41;
        };
      };
    };
  };
}
