{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
in {
  options.features.cli.git.enable = mkEnableOption "enable extended git configuration";

  config = mkIf cfg.enable {
    home.file.sshcontrol = {
      text = builtins.readFile ../../../secrets/sshcontrol;
      target = "${config.home.homeDirectory}/.gnupg/sshcontrol";
    };

    programs.git = {
      enable = true;
      userName = "gunnar";
      userEmail = "gunnarhovik@outlook.com";
      extraConfig = {
        commit.gpgsign = true;
        gpg.program = "${pkgs.gnupg}/bin/gpg";
        user.signingKey = "BF48B4E0C22B5C18";
      };
    };
  };
}
