{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.obico;
  stateDir = "/data/obico";
  port = 3334;
  net = [ "--network=obico" ];
  units = map (n: "podman-obico-${n}.service") [
    "redis"
    "ml"
    "web"
    "tasks"
  ];

  webBase = {
    image = "localhost/obico-web";
    environmentFiles = [ config.sops.secrets.obico-env.path ];
    volumes = [
      "${stateDir}/backend:/app"
      "${stateDir}/frontend:/frontend"
    ];
    environment = {
      OCTOPRINT_TUNNEL_PORT_RANGE = "0-0";
      REDIS_URL = "redis://redis:6379";
      DATABASE_URL = "sqlite:////app/db.sqlite3";
      INTERNAL_MEDIA_HOST = "http://web:${toString port}";
      ML_API_HOST = "http://ml_api:3333";
      SITE_USES_HTTPS = "False";
      SITE_IS_PUBLIC = "False";
      CSRF_TRUSTED_ORIGINS = ''["http://${cfg.address}:${toString port}"]'';
      ACCOUNT_ALLOW_SIGN_UP = "False";
      DEBUG = "False";
    };
  };
in
{
  options.srvs.obico = {
    enable = mkEnableOption "Enable and configure obico";
    address = mkOption {
      type = types.str;
      description = "LAN address the web UI binds to (reachable by the printer)";
    };
    gpu = mkEnableOption "Nvidia GPU acceleration for the ml_api container";
  };

  config = mkIf cfg.enable {
    # Expected keys: DJANGO_SECRET_KEY, TELEGRAM_BOT_TOKEN, optionally EMAIL_HOST*, DEFAULT_FROM_EMAIL
    sops.secrets.obico-env = {
      mode = "0400";
    };

    hardware.nvidia-container-toolkit.enable = mkIf cfg.gpu true;
    virtualisation.containers.registries.search = [ "docker.io" ];

    networking.firewall.allowedTCPPorts = [ port ];

    systemd.services.obico-prep = {
      description = "Clone obico-server and build its images";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      before = units;
      requiredBy = units;
      path = [
        pkgs.podman
        pkgs.git
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "1h";
      };
      script = ''
        [ -d ${stateDir}/.git ] || git clone -b release https://github.com/TheSpaghettiDetective/obico-server.git ${stateDir}
        podman network exists obico || podman network create obico
        podman build -t localhost/obico-web ${stateDir}/backend
        podman build -t localhost/obico-ml ${stateDir}/ml_api
      '';
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        obico-redis = {
          image = "docker.io/library/redis:7.2-alpine";
          extraOptions = net ++ [ "--network-alias=redis" ];
        };

        obico-ml = {
          image = "localhost/obico-ml";
          environment.FLASK_APP = "server.py";
          cmd = [
            "bash"
            "-c"
            "gunicorn --bind 0.0.0.0:3333 --workers 1 wsgi"
          ];
          extraOptions =
            net ++ [ "--network-alias=ml_api" ] ++ optionals cfg.gpu [ "--device=nvidia.com/gpu=all" ];
        };

        obico-web = webBase // {
          ports = [ "${cfg.address}:${toString port}:${toString port}" ];
          dependsOn = [
            "obico-redis"
            "obico-ml"
          ];
          cmd = [
            "sh"
            "-c"
            "python manage.py migrate && python manage.py collectstatic -v 2 --noinput && daphne -b 0.0.0.0 -p ${toString port} config.routing:application"
          ];
          extraOptions = net ++ [ "--network-alias=web" ];
        };

        obico-tasks = webBase // {
          dependsOn = [ "obico-redis" ];
          cmd = [
            "sh"
            "-c"
            "celery -A config worker --beat -l info -c 2 -Q realtime,celery"
          ];
          extraOptions = net ++ [ "--network-alias=tasks" ];
        };
      };
    };
  };
}
