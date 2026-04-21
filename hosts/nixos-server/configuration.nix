{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./srvs
  ];

  # Bootloader.
  boot = {
    supportedFilesystems = [ "zfs" ];
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

  # Networking
  networking = {
    hostName = "nixos-server";
    hostId = "85eef91f";
    useNetworkd = false;
    useDHCP = false;
    firewall.enable = false;
    nftables = {
      enable = true;
      tables = {
        filter = {
          family = "inet";
          content = ''
            chain input {
              type filter hook input priority 0; policy accept;
            }
            chain forward {
              type filter hook forward priority 0; policy accept;
            }
            chain output {
              type filter hook output priority 0; policy accept;
            }
          '';
        };
        nat = {
          family = "ip";
          content = ''
            chain postrouting {
              type nat hook postrouting priority 100;
              ip saddr 10.0.0.0/8 iifname "br-ex" oifname "bond0" masquerade
            }
          '';
        };
      };
    };
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
        };
      };
      "20-br-ex" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-ex";
        };
      };
      "20-br-maas" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-maas";
        };
      };
    };
    networks = {
      "30-eno1" = {
        matchConfig.Name = "eno1";
        networkConfig.Bond = "bond0";
      };
      "30-eno2" = {
        matchConfig.Name = "eno2";
        networkConfig.Bond = "bond0";
      };
      "40-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig.RequiredForOnline = "routable";
        networkConfig.LinkLocalAddressing = "no";
        address = [ "10.0.0.3/24" ];
        routes = [
          { Gateway = "10.0.0.1"; }
        ];
      };
      "50-br-ex" = {
        matchConfig.Name = "br-ex";
        networkConfig.ConfigureWithoutCarrier = true;
        address = [ "10.10.10.10/24" ];
      };
      "50-br-maas" = {
        matchConfig.Name = "br-maas";
        networkConfig.ConfigureWithoutCarrier = true;
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
    fail2ban.enable = true;
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
      staticHostMap."100.100.0.1" = [ "157.151.180.100:4242" ];
      lighthouses = [ "100.100.0.1" ];
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

    pcscd.enable = true;
    zfs.autoScrub.enable = true;
    resolved = {
      enable = true;
      settings.Resolve.DNS = [ "100.100.0.2" ];
    };
  };

  # Environment
  environment = {
    variables = {
      "FLAKE_BRANCH" = "nixos-server";
    };

    # Packages
    systemPackages = with pkgs; [
      python315
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
      juju
      kubectl
      kubectx
      qemu-utils
      thin-provisioning-tools
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    fish = {
      enable = true;
      shellAliases = {
        "fcst" = "ficsit-cli";
        "lxc" = "incus";
      };
    };
  };

  # Services
  srvs = {
    media.enable = true;
    nvidia.enable = true;
    satisfactory = {
      enable = false;
      launchOptions = "-multihome=0.0.0.0";
    };
    traefik.enable = true;
    about.enable = true;
    opencloud = {
      enable = true;
      office = true;
    };
    adblock.enable = true;
    authentik.enable = true;
    valheim.enable = true;
  };

  # Incus
  virtualisation.incus = {
    enable = true;
  };

  # User changes
  users.users.gunnar.extraGroups = [
    "incus"
    "incus-admin"
  ];

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
