{lib, ...}: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        extraLuaFiles = [
          (builtins.path {
            path = ./nvim/nvim-config.lua;
            name = "nvim-config";
          })
        ];

        theme = lib.mkForce {
          enable = true;
          name = "dracula";
        };
        autopairs.nvim-autopairs.enable = true;

        options = {
          tabstop = 2;
          shiftwidth = 2;
          backup = false;
        };

        utility = {
          images.image-nvim = {
            enable = true;
            setupOpts = {
              backend = "kitty";
              integrations.markdown = {
                enable = true;
                downloadRemoteImages = true;
                onlyRenderAtCursor = true;
              };
            };
          };
          preview.markdownPreview = {
            enable = true;
            autoClose = true;
            autoStart = true;
            customPort = "1111";
          };
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          otter-nvim = {
            enable = true;
            mappings.toggle = "<C-l>";
          };
        };

        treesitter = {
          enable = true;
          addDefaultGrammars = true;
          autotagHtml = true;
          context.enable = true;
          indent = {
            enable = true;
            disable = ["yaml"];
          };
          highlight = {
            enable = true;
            additionalVimRegexHighlighting = true;
          };
        };

        visuals = {
          cinnamon-nvim.enable = true;
          indent-blankline.enable = true;
          nvim-cursorline.enable = true;
          fidget-nvim.enable = true;
        };

        languages = {
          enableDAP = true;
          enableExtraDiagnostics = true;
          enableFormat = true;
          enableTreesitter = true;

          nix = {
            enable = true;
            lsp.server = "nixd";
          };
          csharp.enable = true;
          bash.enable = true;
          java.enable = true;
          html.enable = true;
          css.enable = true;
          rust.enable = true;
          markdown.enable = true;
          clang.enable = true;
          haskell.enable = true;
          python = {
            enable = true;
            lsp.server = "pyright";
          };
        };

        autocomplete.nvim-cmp = {
          enable = true;
          mappings = {
            confirm = "<C-f>";
            next = "<Tab>";
            previous = "<S-Tab>";
            close = "<Esc";
            scrollDocsUp = "<C-Up>";
            scrollDocsDown = "<C-Down>";
          };
        };
      };

      vim.ui.borders.plugins = {
        nvim-cmp = {
          enable = true;
          style = "solid";
        };
      };
    };
  };
}
