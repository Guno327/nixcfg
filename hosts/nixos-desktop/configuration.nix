{
  pkgs,
  config,
  ...
}: {
  imports = [./hardware-configuration.nix];

  # Boot.
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 10;
        secureBoot.enable = true;
        extraEntries = ''
          /Windows
          comment: Windows Boot Manager
          protocol: efi
          path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
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
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    enableIPv6 = false;
  };

  hardware = {
    xpadneo.enable = true;

    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # Tablet Drivers
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
      blacklistedKernelModules = [
        "hid-uclogic"
        "wacom"
      ];
    };

    # Graphics
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # xdg
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal];
    config.common.default = ["gtk"];
  };

  # Services
  services = {
    # Enable timesyncd
    timesyncd.enable = true;

    # Auto login
    displayManager.autoLogin = {
      enable = true;
      user = "gunnar";
    };

    # X11
    displayManager.defaultSession = "none+i3";
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
      videoDrivers = ["amdgpu"];
      enableTearFree = true;
      displayManager.lightdm = {
        enable = true;
        greeter.enable = false;
      };
    };

    # Pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      allowSFTP = true;
    };

    # Printing
    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    printing = {
      enable = true;
      drivers = [
        pkgs.hplip
        pkgs.gutenprint
      ];
    };

    # Nebula Mesh
    nebula.networks."mesh" = {
      staticHostMap."100.100.0.1" = ["192.227.212.190:4242"];
      lighthouses = ["100.100.0.1"];
      key = config.sops.secrets."nebula/desktop.key".path;
      cert = config.sops.secrets."nebula/desktop.crt".path;
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
    };

    blueman.enable = true;
    resolved.enable = true;
  };

  boot.initrd.services.udev.rules = ''
    ATTRS{idVendor}=="6964", ATTRS{idProduct}=="0080", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
  # Security
  security = {
    pam.services = {
      i3lock-color = {};
    };

    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };

  # Set your time zone.
  time = {
    timeZone = "America/New_York";
    hardwareClockInLocalTime = true;
  };

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
      extraCompatPackages = with pkgs; [proton-ge-bin];
    };

    wireshark.enable = true;
    fish.enable = true;
    adb.enable = true;
  };

  # Environment
  environment = {
    sessionVariables = {
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
      tpm2-tss
    ];
  };

  # Virt
  users.groups.libvirtd.members = ["gunnar"];
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
