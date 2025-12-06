{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  # Boot.
  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos-lts;
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 3;
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
    extraPortals = [ pkgs.xdg-desktop-portal ];
    config.common.default = [ "gtk" ];
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
      videoDrivers = [ "amdgpu" ];
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

    autorandr = {
      enable = true;
      hooks.postswitch.i3 = "${pkgs.i3}/bin/i3-msg restart";
      profiles = {
        "default" = {
          fingerprint = {
            DisplayPort-0 = "00ffffffffffff0010acd9414c4a5241081f0104b53c22783b8cb5af4f43ab260e5054a54b00d100d1c0b300a94081808100714fe1c0565e00a0a0a029503020350055502100001a000000ff00334452545038330a2020202020000000fc0044454c4c205332373231444746000000fd0030a5fafa41010a202020202020014c020337f1513f101f200514041312110302010607151623090707830100006d1a0000020b30a5000f623d623de305c000e606050162623ef4fb0050a0a028500820680055502100001a40e7006aa0a067500820980455502100001a6fc200a0a0a055503020350055502100001a000000000000000000000000000000000000a5";
            DisplayPort-1 = "00ffffffffffff0038a3072b000000000e180104a5362078e22195a756529c26105054bfef8081008140818081c095009040b300a9c0023a801871382d40582c45001f3d2100001e000000fd00374c1f5311000a202020202020000000fc0045323433574d690a2020202020000000ff0034343130373231324e410a202001b1020313c1469004031f13122309070783010000011d007251d01e206e2855001f3d2100001e8c0ad08a20e02d10103e96001f3d210000188c0ad090204031200c4055001f3d21000018023a80d072382d40102c45801f3d2100001e00000000000000000000000000000000000000000000000000000000000000000000000011";
          };
          config = {
            DisplayPort-0 = {
              enable = true;
              primary = true;
              position = "1080x220";
              mode = "2560x1440";
              rate = "165.00";
            };
            DisplayPort-1 = {
              enable = true;
              primary = false;
              position = "0x0";
              mode = "1920x1080";
              rate = "60.00";
              rotate = "right";
            };
          };
        };
      };
    };

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      allowSFTP = true;
    };

    printing = {
      enable = true;
      drivers = [
        pkgs.hplip
        pkgs.gutenprint
      ];
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
      hyprlock = { };
      i3lock-color.enable = true;
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
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
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
      tpm2-tss
    ];
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Virt
  users.groups.libvirtd.members = [ "gunnar" ];
  virtualisation = {
    libvirtd.enable = true;
    waydroid.enable = true;
    spiceUSBRedirection.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
