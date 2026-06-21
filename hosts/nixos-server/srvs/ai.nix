{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.ai;
  openclawConfig = pkgs.writeText "openclaw.json" (
    builtins.toJSON {
      secrets.providers.gateway_token_file = {
        source = "file";
        path = "/home/node/.openclaw/gateway-token";
        mode = "singleValue";
      };

      gateway = {
        mode = "local";
        bind = "lan";
        port = 18789;
        auth.token = {
          source = "file";
          provider = "gateway_token_file";
          id = "value";
        };
        controlUi.allowedOrigins = [
          "https://ai.ghov.net"
          "http://localhost:18789"
          "http://127.0.0.1:18789"
        ];
      };

      models.providers.ollama = {
        api = "ollama";
        baseUrl = "http://host.containers.internal:11434";
        apiKey = "ollama";
        models = [
          {
            id = "qwen3.5:9b";
            name = "Qwen3.5";
            params = {
              temperature = 0.3;
              top_p = 0.9;
              top_k = 20;
              repeat_penalty = 1.1;
              min_p = 0.05;
              num_ctx = 98304;
            };
          }
        ];
      };
      agents.defaults.model.primary = "ollama/qwen3.5:9b";

      plugins.entries.searxng = {
        enabled = true;
        config.webSearch.baseUrl = "http://searxng:8080";
      };
      tools.web.search.provider = "searxng";
    }
  );
in
{
  options.srvs.ai = {
    enable = mkEnableOption "Enable local ai stack";
  };

  config = mkIf cfg.enable {
    services.traefik.dynamicConfigOptions = mkIf config.srvs.traefik.enable {
      http = {
        routers.ai-router = {
          rule = "Host(`ai.ghov.net`)";
          entryPoints = [ "websecure" ];
          priority = 10;
          middlewares = [ "authentik" ];
          service = "ai-service";
        };
        services.ai-service.loadBalancer.servers = [
          {
            url = "http://127.0.0.1:18789";
            preservePath = true;
          }
        ];
      };
    };

    sops.secrets.openclaw-token = {
      owner = "gunnar";
      mode = "0400";
    };

    networking.firewall.extraInputRules = ''
      ip saddr 10.89.0.0/24 tcp dport 11434 accept
    '';

    boot = {
      initrd.kernelModules = [ "amdgpu" ];
      kernelParams = [
        "pci=noaer"
        "pcie_aspm=off"
        "amdgpu.runpm=0"
      ];
    };
    environment.systemPackages = [ pkgs.ollama-rocm ];

    nixpkgs.config.rocmSupport = true;
    hardware.graphics.enable = true;
    hardware.amdgpu.opencl.enable = true;

    services = {
      ollama = {
        enable = true;
        package = pkgs.ollama-vulkan;
        host = "0.0.0.0";
        environmentVariables = {
          OLLAMA_VULKAN = "1";
          GGML_VK_VISIBLE_DEVICES = "0";
          OLLAMA_FLASH_ATTENTION = "0";
        };
        loadModels = [ "qwen3.5:9b" ];
      };
    };

    virtualisation = {
      podman.enable = true;
      oci-containers = {
        backend = "podman";
        containers.openclaw = {
          image = "ghcr.io/openclaw/openclaw:latest";
          ports = [ "127.0.0.1:18789:18789" ];
          volumes = [
            "openclaw:/home/node/.openclaw"
            "${openclawConfig}:/home/node/.openclaw/openclaw.json:ro"
            "${config.sops.secrets.openclaw-token.path}:/home/node/.openclaw/gateway-token:ro"
          ];
          extraOptions = [ "--network=ollama-net" ];
          environment = {
            OLLAMA_HOST = "http://host.containers.internal:11434";
            OPENCLAW_GATEWAY_MODE = "local";
          };
        };
        containers.searxng = {
          image = "docker.io/searxng/searxng:latest";
          volumes = [ "searxng:/etc/searxng" ];
          environment.SEARXNG_BASE_URL = "http://searxng:8080/";
          extraOptions = [
            "--network=ollama-net"
            "--security-opt=no-new-privileges"
          ];
        };
      };
    };
  };
}
