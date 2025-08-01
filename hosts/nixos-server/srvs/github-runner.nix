{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.srvs.github-runner;
in {
  options.srvs.github-runner.enable = mkEnableOption "Enable github runner";
  config = mkIf cfg.enable {
    users = {
      users.github = {
        name = "github";
        isSystemUser = true;
        group = "github";
      };
      groups.github = {};
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/github-runners 774 github github -"
      "d /var/lib/github-runners/pkgs-runner 774 github github -"
    ];

    services.github-runners.pkgs-runner = {
      enable = true;
      workDir = "/var/lib/github-runners/pkgs-runner";
      user = "github";
      url = "https://github.com/Guno327/pkgs";
      tokenFile = "/home/gunnar/.nixcfg/secrets/pkgs-runner.token";
      extraPackages = [pkgs.nix-update];
    };
  };
}
