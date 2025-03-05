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
    hostId = "00000001";
    firewall.enable = false;
  };

  # Setup bridge
  networking = {
    bridges."br0".interfaces = ["eno1"];
    interfaces."br0".ipv4.addresses = [
      {
        address = "10.0.0.3";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.0.0.1";
    nameservers = ["10.0.0.1"];
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
      inputs.agenix.packages."${system}".default
      mullvad
      tmux
      nh
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    ssh.startAgent = true;
    fish.enable = true;
  };

  # Services
  srvs = {
    test.enable = false;
    media.enable = true;
    pufferpanel.enable = true;
    nginx.enable = true;
    site.enable = true;
    gitlab.enable = true;
  };

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
