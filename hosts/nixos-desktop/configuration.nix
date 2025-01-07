{
  pkgs,
  inputs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 5;
  };

  networking = {
    hostName = "nixos-desktop";
    interfaces."enp7s0".ipv4.addresses = [
      {
        address = "10.0.0.109";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.0.0.1";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  # Networking
  networking.networkmanager.enable = true;

  # Services
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    xserver = {
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };

      # Graphics
      videoDrivers = ["amdgpu"];

      desktopManager.runXdgAutostartIfNone = true;
    };

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      allowSFTP = true;
    };
  };

  # Security
  security.pam.services.hyprlock = {};

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

    # Japanese IME
    inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-mozc-ut
          fcitx5-gtk
        ];
        waylandFrontend = true;
      };
    };
  };

  # Programs
  programs = {
    virt-manager.enable = true;

    # Enable AppImage support
    appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run;
    };

    # Steam
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    fish.enable = true;
    ssh.startAgent = true;
  };

  # Environment
  environment = {
    variables = {
      "FLAKE_BRANCH" = "nixos-desktop";
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      pavucontrol
      inputs.zen-browser.packages.${pkgs.system}.default
      mullvad
    ];
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

  # Graphics
  boot.initrd.kernelModules = ["amdgpu"];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # KVM
  users.groups.libvirtd.members = ["gunnar"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Steam
  services.mullvad-vpn.enable = true;

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
