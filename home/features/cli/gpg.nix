{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.gpg;
in {
  options.features.cli.gpg.enable = mkEnableOption "enable extended gpg configuration";
  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      mutableKeys = true;
      mutableTrust = true;
    };
    services.gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-curses;
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };
}
