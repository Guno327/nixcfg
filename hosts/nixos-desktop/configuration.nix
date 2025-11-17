{
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix];

  # Boot.
  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos-lts;
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        gfxmodeBios = "auto";
        extraEntries = ''
           #UEFI
           menuentry 'UEFI Firmware Settings' --id 'uefi-firmware' {
           fwsetup
          }
        '';
      };
    };
  };

  # Networking
  networking = {
    hostName = "nixos-desktop";
    useDHCP = false;
    interfaces.enp7s0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.100";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "10.0.0.1";
    nameservers = ["1.1.1.1" "8.8.8.8"];
    enableIPv6 = false;
  };

  # Bluetooth
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    xpadneo.enable = true;
  };

  # Tablet Drivers
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
    blacklistedKernelModules = [
      "hid-uclogic"
      "wacom"
    ];
  };

  # xdg
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal];
    config.common.default = ["gtk"];
  };

  # Services
  services = {
    displayManager = {
      defaultSession = "i3";
      ly.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    flatpak = {
      enable = true;
      update.onActivation = true;
      uninstallUnmanaged = true;
      packages = [
        "app.zen_browser.zen"
        "com.adamcake.Bolt"
      ];
      overrides = {
        global = {
          Context.filesystems = [
            "/home"
            "/run/current-system/sw/bin:ro"
            "/nix/store:ro"
          ];
        };
      };
    };

    xserver = {
      # i3
      enable = true;
      windowManager.i3.enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };

      # Graphics
      videoDrivers = ["amdgpu"];
      enableTearFree = true;
      desktopManager.runXdgAutostartIfNone = true;

      # Disable sleep
      config = lib.mkAfter ''
        Section "ServerFlags"
          Option "BlankTime" "10"
          Option "StandbyTime" "0"
          Option "SuspendTime" "0"
          Option "OffTime" "0"
        EndSection
      '';
    };

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      allowSFTP = true;
    };

    printing = {
      enable = true;
      drivers = [pkgs.hplip pkgs.gutenprint];
    };

    blueman.enable = true;
    resolved.enable = true;
  };

  boot.initrd.services.udev.rules = ''
    ATTRS{idVendor}=="6964", ATTRS{idProduct}=="0080", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
  # Security
  security.pam.services = {
    hyprlock = {};
    i3lock-color.enable = true;
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
      extraCompatPackages = with pkgs; [proton-ge-bin];
    };

    wireshark.enable = true;
    fish.enable = true;
    adb.enable = true;
  };

  # Environment
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      STEAM_APP_DIR = "/home/gunnar/ssd/SteamLibrary/steamapps";
    };

    systemPackages = with pkgs; [
      pavucontrol
      xorg.xhost
      gamescope
      wine
      nh
      git-crypt
      wine64
      wine-wayland
      winetricks
      gamemode
      chromium
      vinegar
    ];
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Virt
  users.groups.libvirtd.members = ["gunnar"];
  virtualisation = {
    libvirtd.enable = true;
    waydroid.enable = true;
    spiceUSBRedirection.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
