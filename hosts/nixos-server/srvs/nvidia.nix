{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.srvs.nvidia;
in {
  options.srvs.nvidia = {
    enable = mkEnableOption "Setup and configure nvidia drivers for transcoding";
  };

  config = mkIf cfg.enable {
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;

      powerManagement = {
        enable = false;
        finegrained = false;
      };
    };
  };
}
