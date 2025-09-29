{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.gnome;
  uint = lib.gvariant.mkUint32;
in {
  options.features.desktop.gnome.enable = mkEnableOption "enable extended gnome configuration";

  config = mkIf cfg.enable {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          disabled-extensions = "disabled";
          enabled-extensions = [
            "native-window-placement@gnome-shell-extensions.gcampax.github.com"
            "pop-shell@system76.com"
            "appindicatorsupport@rgcjonas.gmail.com"
          ];
          favorite-apps = [
            "foot.desktop"
            "app.zen_browser.zen.desktop"
            "com.valvesoftware.Steam.desktop"
            "discord.desktop"
          ];
          had-bluetooth-devices-setup = true;
          remember-mount-password = false;
          welcome-dialog-last-shown-version = "42.4";
        };
        "org/gnome/shell/extensions/pop-shell" = {
          tile-by-default = true;
          smart-gaps = true;
          gap-outer = uint 0;
          gap-inner = uint 0;
          move-cursor-focus-location = uint 4;
          active-hint = true;
          active-hint-border-radius = uint 0;
          hint-color-rgba = "rgba(138,255,128)";
          stacking-with-mouse = false;

          tile-enter = ["<Super>t"];
          focus-left = ["<Super>Left"];
          focus-right = ["<Super>Right"];
          focus-up = ["<Super>Up"];
          focus-down = ["<Super>Down"];
        };
        "org/gnome/desktop/interface" = {
          clock-show-seconds = true;
          clock-show-weekday = true;
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
          font-antialiasing = "grayscale";
          font-hinting = "slight";
          toolkit-accessibility = true;
          show-batter-percentage = true;
        };
        "org/gnome/desktop/screensaver" = {
          picture-uri = "file:///flake/home/gunnar/wallpaper.png";
          color-shading-type = "solid";
          picture-options = "zoom";
        };
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-battery-timeout = 1800;
        };
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-temperature = uint 3700;
        };
        "org/gnome/mutter" = {
          dynamic-workspaces = false;
        };
        "org/gnome/desktop/session" = {
          idle-delay = uint 0;
        };
        "org/gnome/desktop/wm/preferences" = {
          num-workspaces = uint 4;
          focus-mode = "mouse";
        };
        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "flat";
          speed = 0.7;
        };
        "org/gnome/desktop/wm/keybindings" = {
          activate-window-menu = "disabled";
          toggle-message-tray = "disabled";
          close = ["<Super>c"];
          maximize = "disabled";
          move-to-monitor-down = "disabled";
          move-to-monitor-left = "disabled";
          move-to-monitor-right = "disabled";
          move-to-monitor-up = "disabled";
          move-to-workspace-down = "disabled";
          move-to-workspace-up = "disabled";
          toggle-maximized = ["<Super>f"];
          unmaximize = "disabled";

          move-to-workspace-1 = ["<Shift><Super>1"];
          move-to-workspace-2 = ["<Shift><Super>2"];
          move-to-workspace-3 = ["<Shift><Super>3"];
          move-to-workspace-4 = ["<Shift><Super>4"];

          switch-to-workspace-1 = ["<Super>1"];
          switch-to-workspace-2 = ["<Super>2"];
          switch-to-workspace-3 = ["<Super>3"];
          switch-to-workspace-4 = ["<Super>4"];

          switch-to-application-1 = "disabled";
          switch-to-application-2 = "disabled";
          switch-to-application-3 = "disabled";
          switch-to-application-4 = "disabled";
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          screensaver = ["<Super>l"];
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "terminal";
          command = "foot";
          binding = "<Super>Return";
        };
      };
    };
  };
}
