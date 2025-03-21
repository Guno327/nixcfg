{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.ssh;
  key_path = "${config.home.homeDirectory}/.ssh/ssh.key";
in {
  options.features.cli.ssh.enable = mkEnableOption "Enable and configure ssh";
  config = mkIf cfg.enable {
    home.file = {
      authorized_keys = {
        text = builtins.readFile ../../../secrets/authorized_keys;
        target = "${config.home.homeDirectory}/.ssh/authorized_keys";
      };
      ssh_key = {
        text = builtins.readFile ../../../secrets/ssh.key;
        target = key_path;
      };
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        server = {
          hostname = "gamer.projecttyco.net";
          user = "gunnar";
          identityFile = key_path;
        };
        desktop = {
          hostname = "10.0.0.109";
          user = "gunnar";
          identityFile = key_path;
        };
      };
    };
  };
}
