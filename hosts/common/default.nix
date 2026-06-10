{
  pkgs,
  lib,
  inputs,
  outputs,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./users
    ./sops.nix
    ./nebula.nix
    ./stylix.nix
  ];

  home-manager = {
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
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

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      accept-flake-config = true;
      auto-optimise-store = true;
      # Set users allowed to use flake command
      trusted-users = [
        "root"
        "gunnar"
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
      (lib.filterAttrs (_: lib.isType "flake")) inputs
    );
    nixPath = [ "/etc/nix/path" ];
  };

  programs.nix-ld.enable = true;

  environment = {
    variables = {
      "NH_FLAKE" = "/flake";
      "GPG_TTY" = "$(tty)";
      "EDITOR" = "nvim";
    };
    shellAliases = {
      "vi" = "nvim";
      "vim" = "nvim";
    };
    systemPackages = [
      inputs.nvim-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  services = {
    resolved = {
      enable = true;
      settings.Resolve = {
        DNS = lib.mkDefault [ "129.159.121.119#dns.ghov.net" ];
        DNSOverTLS = lib.mkDefault true;
      };
    };
    openvpn.servers = {
      us-work = {
        autoStart = false;
        config = ''
          client
          nobind
          remote us.sesame.canonical.com 17572
          ca ${config.sops.secrets."canonical_ca.crt".path}
          cert ${config.sops.secrets."canonical-guno327.crt".path}
          key ${config.sops.secrets."canonical-guno327.key".path}
          tls-auth ${config.sops.secrets."canonical_ta.key".path} 1
          compress lzo
          dev tun
          proto udp
          verify-x509-name 'access.is' name
          remote-cert-tls server
          cipher AES-128-CBC
          persist-key
          persist-tun
          user nobody
          group nogroup
          keepalive 10 60
          script-security 2
          auth-nocache
        '';
      };
    };
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
      material-symbols
      material-icons
    ];
  };

}
