{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.dev;
  github_pat = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/github.pat);
in {
  options.features.cli.dev.enable = mkEnableOption "enable configuration for devenv";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
    ];

    nix.settings = {
      access-tokens = ["github.com=${github_pat}"];
    };

    programs.direnv = {
      enable = true;
    };
  };
}
