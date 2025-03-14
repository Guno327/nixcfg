{
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        statusline.lualine.enable = true;
        autopairs.nvim-autopairs.enable = true;

        theme = {
          enable = true;
          name = "dracula";
          style = "dark";
        };

        options = {
          tabstop = 2;
          shiftwidth = 2;
          backup = false;
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
          nvim-web-devicons.enable = true;

          fidget-nvim = {
            enable = true;
            setupOpts.intergration.nvim-tree.enable = true;
          };
        };

        languages = {
          enableDAP = true;
          enableExtraDiagnostics = true;
          enableFormat = true;
          enableLSP = true;
          enableTreesitter = true;

          nix.enable = true;
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
