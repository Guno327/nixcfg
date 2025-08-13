{pkgs, ...}: {
  imports = [./hardware-configuration.nix];

  # Bootloader.
  boot = {
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

  # Enable networking
  networking.hostName = "nixos-laptop";
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    xpadneo.enable = true;
  };

  # Services
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    flatpak = {
      enable = true;
      packages = [
        {
          appId = "community.pathofbuilding.PathOfBuildin";
          origin = "flathub";
        }
        {
          appId = "com.valvesoftware.Steam";
          origin = "flathub";
        }
        {
          appId = "app.zen_browser.zen";
          origin = "flathub";
        }
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

    blueman.enable = false;
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
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    fish.enable = true;
  };

  # Environment
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [
      pavucontrol
      nh
      git-crypt
      blueman
      nvtopPackages.amd
    ];
  };

  # Security
  security.pam.services.hyprlock = {};

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Graphics
  boot.initrd.kernelModules = ["amdgpu"];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia.prime = {
    amdgpuBusId = "pci@0000:06:00.0";
    nvidiaBusId = "pci@0000:03:00.0";
  };

  # KVM
  users.groups.libvirtd.members = ["gunnar"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Lid Handling
  services.logind.lidSwitchExternalPower = "ignore";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11"; # DO NOT CHANGE
}
