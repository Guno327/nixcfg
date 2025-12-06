{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.cli.git;
in
{
  options.features.cli.git.enable = mkEnableOption "enable extended git configuration";

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        commit.gpgsign = true;
        gpg.program = "${pkgs.gnupg}/bin/gpg";
        user = {
          name = "guno327";
          email = "accounts@ghov.net";
          signingKey = "BF48B4E0C22B5C18";
        };
      };
    };
  };
}
