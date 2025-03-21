{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./srvs
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 5;
  };

  # Setup networking
  networking = {
    hostName = "nixos-server";
    hostId = "85eef91f";
    firewall.enable = false;
  };

  # Setup bridge
  networking = {
    interfaces."eno1".ipv4.addresses = [
      {
        address = "10.0.0.3";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.0.0.1";
    nameservers = ["10.0.0.3" "10.0.0.1"];
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

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
    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      allowSFTP = true;
      settings = {
        PasswordAuthentication = false;
      };
    };

    mullvad-vpn.enable = true;
    pcscd.enable = true;
  };

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    persistent = true;
    dates = "daily";
    flags = [
      "-L"
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
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
      docker-compose
      curl
      jq
      openresolv
      wireguard-tools
      wg-netmanager
      git-crypt
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    fish.enable = true;
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  users.extraUsers.gunnar.extraGroups = ["docker" "media"];
  virtualisation.oci-containers.backend = "docker";

  # Services
  srvs = {
    nginx.enable = true;
    media.enable = true;
    steam = {
      enable = true;
      satisfactory.enable = false;
    };
    minecraft = {
      enable = false;
      name = "ftb-skies";
      type = "FTBA";
      id = "103";
    };
    pihole.enable = true;
  };

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
