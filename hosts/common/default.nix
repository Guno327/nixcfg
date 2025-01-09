{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./users
    inputs.home-manager.nixosModules.home-manager
    ./nvf-configuration.nix
  ];

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs outputs;};
  };

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      # Set users allowed to use flake command
      trusted-users = [
        "root"
        "gunnar"
      ];
    };


    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    registry = (lib.mapAttrs (_: flake: {inherit flake;})) (
      (lib.filterAttrs (_: lib.isType "flake")) inputs
    );
    nixPath = ["/etc/nix/path"];
  };
  
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableFishIntegration = true;
    };
  };

  users.defaultUserShell = pkgs.fish;
}
