{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.opencloud;
in
{
  options.srvs.opencloud = {
    enable = mkEnableOption "Enable and configure opencloud";
    office = mkEnableOption "Enable office suite integration";
  };

  config = mkIf cfg.enable {
    services.traefik.dynamicConfigOptions = mkIf config.srvs.traefik.enable {
      http = {
        routers = {
          data-router = {
            rule = "Host(`data.ghov.net`)";
            entryPoints = [ "websecure" ];
            priority = 10;
            service = "data-service";
          };
          office-router = mkIf cfg.office {
            rule = "Host(`office.ghov.net`)";
            entryPoints = [ "websecure" ];
            priority = 10;
            service = "office-service";
          };
        };
        services = {
          data-service.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:9200";
              preservePath = true;
            }
          ];
          office-service.loadBalancer.servers = mkIf cfg.office [
            {
              url = "http://127.0.0.1:9201";
              preservePath = true;
            }
          ];
        };
      };
    };

    services = {
      opencloud = {
        enable = true;
        url = "https://data.ghov.net";
        address = "127.0.0.1";
        port = 9200;
        stateDir = "/data/opencloud";
        settings = {
          proxy = {
            role_assignment = {
              driver = "oidc";
              oidc_role_mapper = {
                role_claim = "groups";
                role_mapping = [
                  {
                    role_name = "admin";
                    claim_value = "Admins";
                  }
                  {
                    role_name = "user";
                    claim_value = "Users";
                  }
                ];
              };
            };
          };
          csp = {
            directives = {
              default-src = [ "'self'" ];
              script-src = [
                "'self'"
                "'unsafe-inline'"
                "'unsafe-eval'"
              ];
              style-src = [
                "'self'"
                "'unsafe-inline'"
              ];
              connect-src = [
                "'self'"
                "blob:"
                "https://raw.githubusercontent.com/opencloud-eu/awesome-apps/"
                "https://update.opencloud.eu/"
                "https://data.ghov.net/"
                "https://auth.ghov.net/"
                "https://office.ghov.net/"
                "wss://office.ghov.net/"
              ];
              frame-src = [
                "'self'"
                "blob:"
                "https://data.ghov.net/"
                "https://auth.ghov.net/"
                "https://office.ghov.net/"
              ];
              form-actions = [
                "'self'"
                "https://data.ghov.net/"
                "https://office.ghov.net/"
              ];
              img-src = [
                "'self'"
                "data:"
                "https:"
                "blob:"
              ];
              font-src = [
                "'self'"
                "data:"
              ];
              object-src = [ "'none'" ];
              base-uri = [ "'self'" ];
              form-action = [ "'self'" ];
              worker-src = [ "'self'" ];
            };
          };
        };
        environment = mkMerge [
          {
            # defaults
            LOG_LEVEL = "error";
            PROXY_TLS = "false";

            # OIDC
            OC_OIDC_ISSUER = "https://auth.ghov.net/application/o/opencloud/";
            WEB_OIDC_CLIENT_ID = "OpenCloudWeb";
            WEB_OIDC_SCOPE = "openid profile email groups";
            PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";
            PROXY_ROLE_ASSIGNMENT_OIDC_CLAIM = "groups";
            PROXY_AUTOPROVISION_ACCOUNTS = "true";
            GRAPH_ASSIGN_DEFAULT_USER_ROLE = "false";
            PROXY_USER_OIDC_CLAIM = "preferred_username";
            PROXY_USER_CS3_CLAIM = "username";
            PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";
            PROXY_OIDC_REWRITE_WELLKNOWN = "true";
            OC_EXCLUDE_RUN_SERVICES = "idp";
            GRAPH_USERNAME_MATCH = "none";
            PROXY_CSP_CONFIG_FILE_LOCATION = "/etc/opencloud/csp.yaml";
          }
          (mkIf cfg.office {
            OC_ADD_RUN_SERVICES = "collaboration";
            COLLABORATION_APP_PRODUCT = "Collabora";
            COLLABORATION_APP_NAME = "Collabora";
            COLLABORATION_APP_ADDR = "https://office.ghov.net";
            COLLABORATION_APP_INSECURE = "false";
            COLLABORATION_WOPI_SRC = "https://data.ghov.net";
          })
        ];
      };
      collabora-online = mkIf cfg.office {
        enable = true;
        port = 9201;
        settings = {
          ssl = {
            enable = false;
            termination = true;
          };

          net = {
            listen = "127.0.0.1";
            post_allow.host = [
              "127.0.0.1"
            ];
          };

          storage.wopi = {
            "@allow" = true;
            host = [ "data.ghov.net" ];
          };

          server_name = "office.ghov.net";
        };
      };
    };
  };
}
