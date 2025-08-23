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
  boot = {
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
    firewall.enable = false;
    useDHCP = false;
    enableIPv6 = false;
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
    nameservers = ["10.0.0.1"];
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
      curl
      jq
      openresolv
      wireguard-tools
      wg-netmanager
      git-crypt
      p7zip
      zfs
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    fish.enable = true;
  };

  # Services
  srvs = {
    cloudflared.enable = true;
    media.enable = true;
    nvidia.enable = true;
    pihole.enable = false;
    mail.enable = false;
    playit.enable = true;
    satisfactory = {
      enable = false;
      launchOptions = "-multihome=0.0.0.0";
    };
    github-runner.enable = true;
    nextcloud.enable = false;
  };

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
