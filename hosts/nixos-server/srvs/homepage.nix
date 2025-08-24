{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.homepage;

  jellyfin_api = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/jellyfin.api);
  sonarr_api = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/sonarr.api);
  radarr_api = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/radarr.api);
  bazarr_api = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/bazarr.api);
  prowlarr_api = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/prowlarr.api);
  jellyseerr_api = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/jellyseerr.api);
  web_pass = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/web_pass);
in {
  options.srvs.homepage = {
    enable = mkEnableOption "Setup and configure homepage-dashboard";
  };

  config = mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = 8082;
      allowedHosts = "dash.ghov.net";
      settings = {
        title = "nixos-server";
        theme = "dark";
        color = "slate";
      };
      services = [
        {
          "Media" = [
            {
              "Jellyfin" = {
                description = "Jellyfin status";
                href = "https://media.ghov.net";
                widget = {
                  type = "jellyfin";
                  url = "http://localhost:8096";
                  key = jellyfin_api;
                  enableBlocks = true;
                };
              };
            }
            {
              "Sonarr" = {
                description = "Sonarr status";
                href = "https://sonarr.ghov.net";
                widget = {
                  type = "sonarr";
                  url = "http://localhost:8989";
                  key = sonarr_api;
                };
              };
            }
            {
              "Radarr" = {
                description = "Radarr status";
                href = "https://radarr.ghov.net";
                widget = {
                  type = "radarr";
                  url = "http://localhost:7878";
                  key = radarr_api;
                };
              };
            }
            {
              "Bazarr" = {
                description = "Bazarr status";
                href = "https://bazarr.ghov.net";
                widget = {
                  type = "bazarr";
                  url = "http://localhost:6767";
                  key = bazarr_api;
                };
              };
            }
            {
              "Prowlarr" = {
                description = "Prowlarr status";
                href = "https://prowlarr.ghov.net";
                widget = {
                  type = "prowlarr";
                  url = "http://localhost:9117";
                  key = prowlarr_api;
                };
              };
            }
            {
              "Jellyseerr" = {
                description = "Jellyseer status";
                href = "https://request.ghov.net";
                widget = {
                  type = "jellyseerr";
                  url = "http://localhost:5000";
                  key = jellyseerr_api;
                };
              };
            }
          ];
        }
        {
          "Files" = [
            {
              "Transmission" = {
                description = "Transmission status";
                href = "https://nixos-server:9091";
                widget = {
                  type = "transmission";
                  url = "http://localhost:9091";
                  username = "admin";
                  password = web_pass;
                };
              };
            }
          ];
        }
      ];
    };
  };
}
