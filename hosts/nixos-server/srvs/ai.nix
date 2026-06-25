{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.ai;
  hermesModelfile = pkgs.writeText "qwen-agent.modelfile" ''
    FROM qwen3.5:9b

    PARAMETER num_ctx 65536
    PARAMETER num_predict -1

    PARAMETER temperature 0.3
    PARAMETER top_p 0.9
    PARAMETER top_k 20
    PARAMETER min_p 0.05
    PARAMETER repeat_penalty 1.1
    PARAMETER repeat_last_n 64
  '';
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
          service = "ai-service";
        };
        services.ai-service.loadBalancer = {
          servers = [
            {
              url = "http://127.0.0.1:1119";
              preservePath = true;
            }
          ];
        };
      };
    };

    sops.secrets = {
      searx-env = {
        owner = "searx";
        mode = "0400";
      };
      hermes-env = {
        owner = config.services.hermes-agent.user;
        mode = "0400";
      };
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
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_CONTEXT_LENGTH = "65536";
          OLLAMA_KV_CACHE_TYPE = "q8_0";
        };
        loadModels = [ "qwen3.5:9b" ];
      };

      searx = {
        enable = true;
        redisCreateLocally = true;
        environmentFile = config.sops.secrets.searx-env.path;
        settings = {
          search.formats = [
            "html"
            "json"
          ];
          search.server = {
            bind_address = "127.0.0.1";
            port = 8888;
            secret_key = "placeholder";
          };
        };
      };

      hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        container = {
          enable = true;
          hostUsers = [ "gunnar" ];
        };
        extraDependencyGroups = [ "web" ];
        settings = {
          model = {
            default = "qwen3.5-agent";
            provider = "custom";
            base_url = "http://127.0.0.1:11434/v1";
            context_length = 65536;
          };
          web.search_backend = "searxng";
          dashboard = {
            public_url = "https://ai.ghov.net";
            oauth = {
              provider = "self-hosted";
              self_hosted = {
                issuer = "https://auth.ghov.net/application/o/hermes/";
                client_id = "hermes-agent";
              };
            };
          };
        };
        environmentFiles = [ config.sops.secrets.hermes-env.path ];
      };
    };

    systemd.services = {
      ollama-hermes-model = {
        description = "Create tuned qwen3.5-agent Ollama model";
        after = [
          "ollama.service"
          "ollama-model-loader.service"
        ];
        requires = [ "ollama.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "ollama";
          Environment = [
            "OLLAMA_HOST=127.0.0.1:11434"
            "HOME=/var/lib/ollama"
          ];
        };
        script = ''
          until ${pkgs.ollama}/bin/ollama list | grep -q 'qwen3.5:9b'; do sleep 2; done
          ${pkgs.ollama}/bin/ollama create qwen3.5-agent -f ${hermesModelfile}
        '';
      };
      hermes-dashboard = {
        description = "Hermes Agent Web Dashboard";
        after = [
          "network.target"
          "hermes-agent.service"
        ];
        wants = [ "hermes-agent.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = config.services.hermes-agent.user;
          Group = config.services.hermes-agent.group;
          EnvironmentFile = config.sops.secrets."hermes-env".path;
          ExecStart = "${config.services.hermes-agent.package}/bin/hermes dashboard --host=0.0.0.0 --port=1119 --no-open";
          Restart = "on-failure";
          RestartSec = 10;
        };
      };
    };
  };
}
