{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.gitlab;
in {
  options.srvs.gitlab.enable = mkEnableOption "Enable gitlab-runner contianer";
  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    services.gitlab-runner = {
      enable = true;
      configFile = "/home/gunnar/.gitlab-runner/config.toml";
    };
  };
}
