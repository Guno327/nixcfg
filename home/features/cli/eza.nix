{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.cli.eza;
in
{
  options.features.cli.eza.enable = mkEnableOption "Enable and alias eza";
  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      extraOptions = [
        "-l"
        "--icons"
        "--git"
      ];
    };

    programs.fish.shellAbbrs = {
      ls = "eza";
      la = "eza -a";
      lt = "eza --tree";
    };
  };
}
