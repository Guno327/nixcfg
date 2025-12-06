{
  pkgs,
  lib,
  ...
}:
{
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  stylix.targets.qt.platform = lib.mkForce "qtct";

  services = {
    tlp.enable = lib.mkForce false;

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    gnome = {
      core-apps.enable = true;
      core-developer-tools.enable = false;
      games.enable = false;
    };

    udev.packages = with pkgs; [ gnome-settings-daemon ];
  };

  environment = {
    gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];
    systemPackages = with pkgs; [
      gnomeExtensions.pop-shell
      gnomeExtensions.appindicator
      gnome-tweaks
      libsForQt5.qt5ct
    ];
  };
}
