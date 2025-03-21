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
    overlays = [
      # Add overlays from flake
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];

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
  programs.nix-ld.enable = true;

  users.defaultUserShell = pkgs.fish;

  environment.variables = {
    "FLAKE" = "/home/gunnar/.nixcfg";
    GPG_TTY = "$(tty)";
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };

  networking.hosts = {
    "10.0.0.3" = ["server"];
    "10.0.0.2" = ["idrac"];
    "10.0.0.1" = ["router"];
    "10.0.0.100" = ["desktop"];
  };

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.fira-code;
        name = "Fira Code";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 12;
        desktop = 12;
        terminal = 14;
        popups = 12;
      };
    };
  };
}
