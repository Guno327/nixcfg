{ config, lib, ... }:
let
  isServer = config.networking.hostName == "nixos-server";
in
lib.mkMerge [
  (lib.mkIf isServer {
    nix.settings.trusted-users = [ "nixbuild" ];
    users.users.nixbuild = {
      isNormalUser = true;
      group = "nixbuild";
      openssh.authorizedKeys.keyFiles = [ ./keys/id_nixbuild.pub ];
    };
    users.groups.nixbuild = { };
  })

  (lib.mkIf (!isServer) {
    sops.secrets.id_nixbuild = {
      owner = "root";
      mode = "0400";
    };
    programs.ssh.knownHosts."nixos-server" = {
      publicKeyFile = ./keys/nixos-server-host.pub;
    };

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "nixos-server";
          sshUser = "nixbuild";
          sshKey = config.sops.secrets.id_nixbuild.path;
          system = "x86_64-linux";
          protocol = "ssh-ng";
          maxJobs = 8;
          speedFactor = 4;
          supportedFeatures = [
            "big-parallel"
            "kvm"
            "nixos-test"
          ];
        }
      ];
      settings = {
        builders-use-substitutes = true;
        max-jobs = 1;
        fallback = true;
      };
    };
  })
]
