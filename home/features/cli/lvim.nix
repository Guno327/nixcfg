{ config, lib, pkgs, ... }: with lib;
let 
  cfg = config.features.cli.lvim;
in {
  options.features.cli.lvim.enable = 
    mkEnableOption "Enable and configure lunarvim";
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ lunarvim pkgs.vimPlugins.otter-nvim ];
    home.file.".config/lvim/config.lua".text = ''
      lvim.plugins = {
        { "Mofiqul/dracula.nvim" },
        { "jmbuhr/otter.nvim" },
        config = function()
          require("otter").activate({"javascript", "python", "rust", "bash"}, true, true, nil)
        end,
      }

      lvim.colorscheme = "dracula"
      require("otter").activate({"javascript", "python", "rust", "bash"}, true, true, nil)
    '';
    programs.fish.shellAbbrs = {
      vim = "lvim";
      nvim = "lvim";
    };
  };
}
