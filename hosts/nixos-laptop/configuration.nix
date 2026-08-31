{
  pkgs,
  config,
  ...
}:
{
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
      dns = "systemd-resolved";
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

    opentabletdriver = {
      enable = true;
      daemon.enable = true;
      blacklistedKernelModules = [
        "hid-uclogic"
        "wacom"
      ];
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

    # Power management
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/wakeup}="enabled"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="<kbd>", ATTR{idProduct}=="<kbd>", ATTR{power/wakeup}="enabled"
      ACTION=="add", SUBSYSTEM=="pci", DRIVER=="xhci_hcd", ATTR{power/wakeup}="enabled"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="6964", ATTR{idProduct}=="0080", ATTR{power/wakeup}="enabled"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="36a7", ATTR{idProduct}=="a870", ATTR{power/wakeup}="disabled"
    '';

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
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        # CPU — amd-pstate active
        CPU_SCALING_GOVERNOR_ON_AC = "powersave"; # correct with amd-pstate; EPP does the work
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 60;

        # GPU
        RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
        RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
        RADEON_DPM_STATE_ON_AC = "performance";
        RADEON_DPM_STATE_ON_BAT = "battery";

        # PCIe / runtime PM
        RUNTIME_PM_ON_AC = "auto";
        RUNTIME_PM_ON_BAT = "auto";
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";

        # USB
        USB_AUTOSUSPEND = 1;
        USB_EXCLUDE_BTUSB = 1;
        USB_DENYLIST = "0bda:8153 6964:0080";
        WOL_DISABLE = "N";

        # Radios
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth";

        # Storage
        DISK_APM_LEVEL_ON_AC = "254";
        DISK_APM_LEVEL_ON_BAT = "128";

        # Battery longevity (via msi-ec)
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
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
      key = config.sops.secrets."nebula/laptop.key".path;
      cert = config.sops.secrets."nebula/laptop.crt".path;
      ca = config.sops.secrets."nebula/ca.crt".path;
    };

    blueman.enable = true;
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
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
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
      pulseaudio
      easyeffects
      deepfilternet
      audacity
    ];
  };

  # Systemd
  systemd = {
    network.links."10-dock-nic" = {
      matchConfig.MACAddress = "b0:7b:25:9a:18:7c";
      linkConfig.WakeOnLan = "magic";
    };
    services.msi-ec-profile = {
      wantedBy = [
        "multi-user.target"
        "post-resume.target"
      ];
      after = [
        "systemd-modules-load.service"
        "post-resume.target"
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        ec=/sys/devices/platform/msi-ec
        echo silent  > $ec/fan_mode
        echo comfort > $ec/shift_mode
        # GPU fan: thresholds 65/70/75/80/85/90 C
        for kv in 82=41 83=46 84=4b 85=50 86=55 87=5a \
                  8a=00 8b=2d 8c=37 8d=41 8e=4b 8f=50; do
          echo $kv > $ec/debug/ec_set
        done
      '';
    };
    user.services = {
      easyeffects = {
        description = "EasyEffects daemon";
        wantedBy = [ "default.target" ];
        after = [ "pipewire.service" ];
        serviceConfig = {
          ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
          Restart = "on-failure";
        };
      };
    };
  };

  # Security
  security = {
    polkit.enable = true;

    pam.services = {
      swaylock.enableGnomeKeyring = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
