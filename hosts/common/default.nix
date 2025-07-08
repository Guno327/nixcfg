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
      outputs.overlays.stable-packages
    ];

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  services.tailscale = {
    enable = true;
    authKeyFile = "/home/gunnar/.nixcfg/secrets/tailscale.key";
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
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  environment.variables = {
    "NH_FLAKE" = "/home/gunnar/.nixcfg";
    GPG_TTY = "$(tty)";
  };

  networking.hosts = {
    "10.0.0.3" = ["server"];
    "10.0.0.2" = ["idrac"];
    "10.0.0.1" = ["router"];
    "10.0.0.100" = ["desktop"];
  };

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code
      font-manager
      font-awesome_5
      noto-fonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
    ];
  };

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    polarity = "dark";

    cursor = {
      package = pkgs.stable.bibata-cursors;
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
