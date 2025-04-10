{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.mail;
in {
  options.srvs.mail = {
    enable = mkEnableOption "Enable mail service";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      mail = {
        autoStart = true;
        image = "analogic/poste.io";
        volumes = ["/home/mail:/data"];
        hostname = "post.projecttyco.net";
        environment = {
          TZ = "America/Denver";
          HTTP_PORT = "8888";
          HTTPS_PORT = "4444";
        };
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };
}
