{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.search;
in
{
  options.srvs.search = {
    enable = mkEnableOption "Enable local search engine";
  };

  config = mkIf cfg.enable {
    services.traefik.dynamicConfigOptions = mkIf config.srvs.traefik.enable {
      http = {
        routers.search-router = {
          rule = "Host(`search.ghov.net`)";
          entryPoints = [ "websecure" ];
          middlewares = [ "authentik" ];
          priority = 10;
          service = "search-service";
        };
        services.search-service.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:8888";
              preservePath = true;
            }
          ];
        };
      };
    };

    sops.secrets = {
      searx = {
        owner = "searx";
        mode = "0400";
      };
      firecrawl-env = { };
    };

    services.searx = {
      enable = true;
      redisCreateLocally = true;

      limiterSettings = {
        real_ip = {
          x_for = 1;
          ipv4_prefix = 32;
          ipv6_prefix = 56;
        };

        botdetection = {
          ip_limit = {
            filter_link_local = true;
            link_token = true;
          };
        };
      };

      settings = {
        general = {
          debug = false;
          instance_name = "ghov.net searx";
          donation_url = false;
          contact_url = false;
          privacypolicy_url = false;
          enable_metrics = false;
        };

        ui = {
          static_use_hash = true;
          default_locale = "en";
          query_in_title = true;
          infinite_scroll = false;
          center_alignment = true;
          default_theme = "simple";
          theme_args.simple_style = "auto";
          search_on_category_select = false;
          hotkeys = "vim";
        };

        search = {
          safe_search = 2;
          autocomplete_min = 2;
          autocomplete = "duckduckgo";
          ban_time_on_fail = 5;
          max_ban_time_on_fail = 120;
          formats = [
            "json"
            "html"
          ];
        };

        server = {
          base_url = "https://search.ghov.net";
          port = 8888;
          bind_address = "127.0.0.1";
          secret_key = config.sops.secrets.searx.path;
          limiter = false;
          public_instance = false;
          image_proxy = true;
          method = "GET";
        };

        engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
          "duckduckgo".disabled = false;
          "brave".disabled = true;
          "bing".disabled = false;
          "mojeek".disabled = true;
          "mwmbl".disabled = false;
          "mwmbl".weight = 0.4;
          "qwant".disabled = true;
          "crowdview".disabled = false;
          "crowdview".weight = 0.5;
          "curlie".disabled = true;
          "ddg definitions".disabled = false;
          "ddg definitions".weight = 2;
          "wikibooks".disabled = true;
          "wikidata".disabled = true;
          "wikiquote".disabled = true;
          "wikisource".disabled = true;
          "wikispecies".disabled = true;
          "wikiversity".disabled = true;
          "wikivoyage".disabled = true;
          "currency".disabled = true;
          "dictzone".disabled = true;
          "lingva".disabled = true;
          "bing images".disabled = false;
          "brave.images".disabled = true;
          "duckduckgo images".disabled = true;
          "google images".disabled = false;
          "qwant images".disabled = true;
          "1x".disabled = true;
          "artic".disabled = false;
          "deviantart".disabled = false;
          "flickr".disabled = true;
          "imgur".disabled = false;
          "library of congress".disabled = false;
          "material icons".disabled = true;
          "material icons".weight = 0.2;
          "openverse".disabled = false;
          "pinterest".disabled = true;
          "svgrepo".disabled = false;
          "unsplash".disabled = false;
          "wallhaven".disabled = false;
          "wikicommons.images".disabled = false;
          "yacy images".disabled = true;
          "bing videos".disabled = false;
          "brave.videos".disabled = true;
          "duckduckgo videos".disabled = true;
          "google videos".disabled = false;
          "qwant videos".disabled = false;
          "dailymotion".disabled = true;
          "google play movies".disabled = true;
          "invidious".disabled = true;
          "odysee".disabled = true;
          "peertube".disabled = false;
          "piped".disabled = true;
          "rumble".disabled = false;
          "sepiasearch".disabled = false;
          "vimeo".disabled = true;
          "youtube".disabled = false;
          "brave.news".disabled = true;
          "google news".disabled = true;
        };

        outgoing = {
          request_timeout = 5.0;
          max_request_timeout = 15.0;
          pool_connections = 100;
          pool_maxsize = 15;
          enable_http2 = true;
        };

        enabled_plugins = [
          "Basic Calculator"
          "Hash plugin"
          "Tor check plugin"
          "Open Access DOI rewrite"
          "Hostnames plugin"
          "Unit converter plugin"
          "Tracker URL remover"
        ];
      };
    };

    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";

    systemd.services.init-firecrawl-network = {
      description = "Create firecrawl podman network";
      after = [ "podman.service" ];
      requires = [ "podman.service" ];
      before = map (n: "podman-${n}.service") [
        "firecrawl-redis"
        "firecrawl-rabbitmq"
        "firecrawl-postgres"
        "firecrawl-playwright"
        "firecrawl-api"
      ];
      wantedBy = map (n: "podman-${n}.service") [
        "firecrawl-redis"
        "firecrawl-rabbitmq"
        "firecrawl-postgres"
        "firecrawl-playwright"
        "firecrawl-api"
      ];
      path = [ pkgs.podman ];
      script = ''
        podman network inspect firecrawl-net >/dev/null 2>&1 || \
          podman network create firecrawl-net
      '';
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
    };

    virtualisation.oci-containers.containers = {
      firecrawl-redis = {
        image = "redis:alpine";
        cmd = [
          "redis-server"
          "--bind"
          "0.0.0.0"
        ];
        extraOptions = [ "--network=firecrawl-net" ];
      };

      firecrawl-rabbitmq = {
        image = "rabbitmq:3-management";
        extraOptions = [ "--network=firecrawl-net" ];
      };

      firecrawl-postgres = {
        image = "ghcr.io/firecrawl/nuq-postgres:latest";
        environment = {
          POSTGRES_USER = "postgres";
          POSTGRES_DB = "postgres";
        };
        environmentFiles = [ config.sops.secrets.firecrawl-env.path ];
        extraOptions = [ "--network=firecrawl-net" ];
      };

      firecrawl-playwright = {
        image = "ghcr.io/firecrawl/playwright-service:latest";
        environment.PORT = "3000";
        extraOptions = [ "--network=firecrawl-net" ];
      };

      firecrawl-api = {
        image = "ghcr.io/firecrawl/firecrawl";
        cmd = [
          "node"
          "dist/src/harness.js"
          "--start-docker"
        ];
        environment = {
          HOST = "0.0.0.0";
          PORT = "3002";
          USE_DB_AUTHENTICATION = "false";
          REDIS_URL = "redis://firecrawl-redis:6379";
          REDIS_RATE_LIMIT_URL = "redis://firecrawl-redis:6379";
          NUQ_RABBITMQ_URL = "amqp://firecrawl-rabbitmq:5672";
          POSTGRES_USER = "postgres";
          POSTGRES_DB = "postgres";
          POSTGRES_HOST = "firecrawl-postgres";
          POSTGRES_PORT = "5432";
          PLAYWRIGHT_MICROSERVICE_URL = "http://firecrawl-playwright:3000/scrape";
          SEARXNG_ENDPOINT = "http://host.containers.internal:8888";
        };
        environmentFiles = [ config.sops.secrets.firecrawl-env.path ];
        ports = [ "127.0.0.1:3002:3002" ];
        extraOptions = [
          "--network=firecrawl-net"
        ];
        dependsOn = [
          "firecrawl-redis"
          "firecrawl-rabbitmq"
          "firecrawl-postgres"
          "firecrawl-playwright"
        ];
      };
    };
  };
}
