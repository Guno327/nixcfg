{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./orangebox.nix
  ];

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
          /Work
          comment: Ubuntu LTS
          protocol: efi
          path: fslabel(UBUNTUBOOT):/EFI/ubuntu/shimx64.efi
        '';
      };
    };
  };

  # Networking
  networking = {
    hostName = "nixos-desktop";
    nameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8" "8.4.4.8"];
    networkmanager = {
      enable = true;
      dns = "none";
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
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
    wlr.enable = true;
    config.common.default = "*";
  };

  # Services
  services = {
    flatpak.enable = true;
    dbus.enable = true;
    gnome.gnome-keyring.enable = true;

    # Time
    geoclue2.enable = true;
    timesyncd.enable = true;
    automatic-timezoned.enable = true;

    # Auto login
    getty = {
      autologinUser = "gunnar";
      autologinOnce = true;
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
  };

  boot.initrd.services.udev.rules = ''
    ATTRS{idVendor}=="6964", ATTRS{idProduct}=="0080", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
  # Security
  security = {
    polkit.enable = true;

    pam.services = {
      swaylock.enableGnomeKeyring = true;
    };

    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
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
    fish = {
      enable = true;
      interactiveShellInit = ''
        setenv GEMINI_API_KEY $(cat ${config.sops.secrets."gemini".path})
      '';
    };
  };

  # Environment
  environment = {
    loginShellInit = ''[[ "$(tty)" == /dev/tty1 ]] && exec sway'';

    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "sway";
      MOZ_ENABLE_WAYLAND = 1;
    };

    systemPackages = with pkgs; [
      pavucontrol
      nh
      tpm2-tss
      nvtopPackages.amd
      android-tools
      sbctl
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
