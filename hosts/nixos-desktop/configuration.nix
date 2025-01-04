{ pkgs, inputs, ... }: {
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  networking = {
    hostName = "nixos-desktop";
    interfaces."enp7so".ipv4.addresses = [{
      address = "10.0.0.109";
      prefixLength = 24;
    }];
    defaultGateway = "10.0.0.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Enable networking
  networking.networkmanager.enable = true;
  
  # Enable audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Security
  security.pam.services.hyprlock = {};

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

  # Graphics
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # KVM
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "gunnar" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Environment varibales
  environment.variables = {
    "FLAKE_BRANCH" = "nixos-desktop";
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable AppImage support
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run;
  };


  # Packages
  environment.systemPackages = with pkgs; [
    pavucontrol
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    allowSFTP = true;
  };

  programs.ssh.startAgent = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.fish.enable = true;

  # Japanese IME
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
  i18n.inputMethod = {
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

  system.stateVersion = "24.11"; # DO NOT CHANGE

}
