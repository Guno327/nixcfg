{ pkgs, config, lib, ... }: with lib;
let 
  cfg = config.features.cli.trim;
in {
  options.features.cli.trim.enable = mkEnableOption "enable extended fish configuration";
  config = mkIf cfg.enable {
    home.file.".scripts/trim-generations.sh" = {
      source = pkgs.fetchurl {
        url = "https://gist.githubusercontent.com/MaxwellDupre/3077cd229490cf93ecab08ef2a79c852/raw/ccb39ba6304ee836738d4ea62999f4451fbc27f7/trim-generations.sh";
        sha256 = "17qi417436d57f7kbnwm70dakqg377rf6ss1r11xp92jq61r71ch";
      };
      executable = true;
    };

    programs.fish.shellAbbrs = 
      { trim = "~/.scripts/trim-generations.sh 3 0 home-manager"; };
  };
}
