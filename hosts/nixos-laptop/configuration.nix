{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 10;
        secureBoot.enable = true;
      };
    };
  };

  # Enable networking
  networking = {
    hostName = "nixos-laptop";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };

  # Hardware
  hardware = {
    xpadneo.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

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

    # tlp
    tlp = {
      enable = true;
      settings = {
        RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
        RADEON_DPM_STATE_ON_BAT = "battery";
        RADEON_POWER_PROFILE_ON_BAT = "low";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_SCALING_GOVERNOR_ON_AC = "performance";

        USB_AUTOSUSPEND_DISABLE = 1;
      };
    };

    # Nebula Mesh
    nebula.networks."mesh" = {
      staticHostMap."100.100.0.1" = ["192.227.212.190:4242"];
      lighthouses = ["100.100.0.1"];
      key = config.sops.secrets."nebula/laptop.key".path;
      cert = config.sops.secrets."nebula/laptop.crt".path;
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

    fish.enable = true;
  };

  # Environment
  environment = {
    loginShellInit = ''[[ "$(tty)" == /dev/tty1 ]] && sway'';

    sessionVariables = {
    };

    systemPackages = with pkgs; [
      pavucontrol
      nh
      nvtopPackages.amd
      sbctl
      android-tools
    ];
  };

  # Security
  security = {
    polkit.enable = true;

    pam.services = {
      swaylock.enableGnomeKeyring = true;
    };
  };

  hardware.nvidia.prime = {
    amdgpuBusId = "pci@0000:06:00.0";
    nvidiaBusId = "pci@0000:03:00.0";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
