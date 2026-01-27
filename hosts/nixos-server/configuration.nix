{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./srvs
    ./sops.nix
  ];

  # Bootloader.
  boot = {
    supportedFilesystems = ["zfs"];
    zfs.forceImportRoot = false;
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        gfxmodeBios = "auto";
      };
    };
  };

  # Setup networking
  networking = {
    hostName = "nixos-server";
    hostId = "85eef91f";
    useDHCP = false;
    enableIPv6 = false;
    defaultGateway = "10.0.0.1";
    nameservers = ["10.0.0.1"];

    interfaces."eno1".ipv4.addresses = [
      {
        address = "10.0.0.3";
        prefixLength = 24;
      }
    ];

    firewall = {
      enable = true;
      interfaces = {
        # Allow SSH on local network for troubleshooting
        "eno1" = {
          allowedTCPPorts = [22];
          allowedUDPPorts = [];
        };

        # All ingress should come across the nebula mesh
        "nebula0" = {
          allowedTCPPorts = [22 80 443];
          allowedUDPPorts = [80 443];
        };
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  #services
  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      allowSFTP = true;
      settings = {
        PasswordAuthentication = false;
      };
    };

    # Nebula Mesh
    nebula.networks."mesh" = {
      tun.device = "nebula0";
      staticHostMap."100.100.0.1" = ["192.227.212.190:4242"];
      lighthouses = ["100.100.0.1"];
      key = config.sops.secrets."nebula/server.key".path;
      cert = config.sops.secrets."nebula/server.crt".path;
      ca = config.sops.secrets."nebula/ca.crt".path;
      firewall = {
        inbound = [
          {
            host = "any";
            proto = "any";
            port = "any";
          }
        ];
        outbound = [
          {
            host = "any";
            proto = "any";
            port = "any";
          }
        ];
      };
      settings = {
        firewall.unsafe_routes = [
          {
            route = "0.0.0.0/0";
            via = "100.100.0.1";
          }
        ];
      };
    };

    mullvad-vpn.enable = true;
    pcscd.enable = true;
    zfs.autoScrub.enable = true;
  };

  # Environment
  environment = {
    variables = {
      "FLAKE_BRANCH" = "nixos-server";
    };

    # Packages
    systemPackages = with pkgs; [
      mullvad
      tmux
      nh
      rclone
      bash
      dive
      curl
      jq
      openresolv
      wireguard-tools
      wg-netmanager
      git-crypt
      p7zip
      zfs
      ficsit-cli
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    fish = {
      enable = true;
      shellAliases = {
        "fcst" = "ficsit-cli";
      };
    };
  };

  # Services
  srvs = {
    media.enable = true;
    nvidia.enable = true;
    satisfactory = {
      enable = true;
      launchOptions = "-multihome=0.0.0.0";
    };
    nginx.enable = true;
    about.enable = true;
    nextcloud.enable = true;
  };

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
