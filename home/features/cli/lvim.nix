{ config, lib, pkgs, ... }: with lib;
let 
  cfg = config.features.cli.lvim;
in {
  options.features.cli.lvim.enable = 
    mkEnableOption "Enable and configure lunarvim";
  
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ lunarvim ];
    home.file.".config/lvim/config.lua".text = ''
      lvim.plugins = {
        { "Mofiqul/dracula.nvim" },
      }

      lvim.colorscheme = "dracula"
    '';
  };
}
