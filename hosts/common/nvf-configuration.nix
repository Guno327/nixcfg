{lib, ...}: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        theme = lib.mkForce {
          enable = true;
          name = "catppuccin";
          style = "mocha";
        };
        autopairs.nvim-autopairs.enable = true;

        options = {
          tabstop = 2;
          shiftwidth = 2;
          backup = false;
        };

        spellcheck = {
          enable = true;
          languages = ["en"];
          programmingWordlist.enable = true;
        };

        diagnostics = {
          enable = true;
          config.virtual_lines = true;
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
            customPort = "1111";
          };
        };

        lsp = {
          enable = true;
          formatOnSave = true;
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
          go.enable = true;
          ts.enable = true;
          python = {
            enable = true;
            lsp.server = "pyright";
          };
        };

        autocomplete.blink-cmp = {
          enable = true;
          friendly-snippets.enable = true;
        };
      };
    };
  };
}
