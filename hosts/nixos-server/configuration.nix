{ pkgs, inputs, ... }: {
  imports =
    [
      ./hardware-configuration.nix
      ./srvs
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Setup networking
  networking = { 
    hostName = "nixos-server";
    firewall.enable = false;
  };

  # Setup bridge
  networking = {
    bridges."br0".interfaces = [ "enp1s0" ];
    interfaces."br0".ipv4.addresses = [{
      address = "192.168.122.87";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.122.1";
    nameservers = [ "192.168.122.1" ];
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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

  # Environment varibales
  environment.variables = {
    "FLAKE_BRANCH" = "nixos-server";
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages."${system}".default
    mullvad
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  programs.ssh.startAgent = true;
  programs.fish.enable = true;

  services.mullvad-vpn.enable = true;

  # Services
  srvs = {
    test.enable = false;
    media.enable = false;
    minecraft.enable = false;
    nginx.enable = false;
    site.enable = true;
  };
  
  system.stateVersion = "24.11"; # DO NOT CHANGE

}
