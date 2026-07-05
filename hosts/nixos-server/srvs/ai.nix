{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.srvs.ai;
  customModelfile = pkgs.writeText "qwen-agent.modelfile" ''
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
              url = "http://127.0.0.1:3080";
              preservePath = true;
            }
          ];
        };
      };
    };

    sops.secrets = {
      librechat-env = {
        mode = "0400";
      };
      meilisearch-master-key = {
        mode = "0400";
      };
    };

    boot = {
      initrd.kernelModules = [ "amdgpu" ];
      kernelParams = [
        "pci=noaer"
        "pcie_aspm=off"
        "amdgpu.runpm=0"
      ];
    };

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
          OLLAMA_MAX_LOADED_MODELS = "2";
          OLLAMA_NUM_PARALLEL = "2";
        };
        loadModels = [
          "qwen3.5:9b"
          "llama3.2:3b"
        ];
      };

      meilisearch = {
        masterKeyFile = config.sops.secrets.meilisearch-master-key.path;
      };

      librechat = {
        enable = true;
        meilisearch.enable = true;
        enableLocalDB = true;
        credentialsFile = config.sops.secrets.librechat-env.path;

        settings = {
          version = "1.3.12";
          cache = true;

          registration.socialLogins = [ "openid" ];

          endpoints = {
            custom = [
              {
                name = "Ollama";
                apiKey = "ollama"; # unused, required by schema
                baseURL = "http://127.0.0.1:11434/v1";
                models = {
                  default = [
                    "qwen3.5-custom"
                    "llama3.2:3b"
                  ];
                  fetch = true;
                };
                titleConvo = true;
                titleModel = "qwen3.5-custom";
              }
              {
                name = "OpenRouter";
                apiKey = "\${OPENROUTER_KEY}";
                baseURL = "https://openrouter.ai/api/v1";
                addParams = {
                  reasoning.exclude = true;
                };
                dropParams = [
                  "stop"
                  "reasoning_effort"
                ];
                modelDisplayLabel = "OpenRouter";
                models = {
                  default = [ "deepseek/deepseek-v4-flash" ];
                  fetch = true;
                };
              }
            ];
          };

          webSearch = {
            searchProvider = "searxng";
            searxngInstanceUrl = "\${SEARXNG_INSTANCE_URL}";
            scraperProvider = "firecrawl";
            firecrawlApiUrl = "\${FIRECRAWL_API_URL}";
            firecrawlApiKey = "\${FIRECRAWL_API_KEY}";
            rerankerType = "none";
          };

          memory = {
            disabled = false;
            personalize = true;
            tokenLimit = 2000;
            maxInputTokens = 12000;
            messageWindowSize = 5;
            agent = {
              provider = "Ollama";
              model = "llama3.2:3b";
              enabled = true;
            };
          };
        };
      };
    };

    systemd.services = {
      ollama-custom-model = {
        description = "Create tuned qwen3.5-custom Ollama model";
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
          ${pkgs.ollama}/bin/ollama create qwen3.5-custom -f ${customModelfile}
        '';
      };
    };
  };
}
