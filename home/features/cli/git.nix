{ config, lib, ... }: with lib; let 
  cfg = config.features.cli.git;
in {
  options.features.cli.git.enable = mkEnableOption "enable extended git configuration";

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Guno327";
      userEmail = "gunnarhovik@outlook.com";

      extraConfig = {
        url = {
          "ssh://git@host" = {
            insteadOf = "otherhost";
          };
          init.defaultBranch = "main";
        };
      };
    };
  };
}
