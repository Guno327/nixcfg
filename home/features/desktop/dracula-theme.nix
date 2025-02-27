{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.dracula-theme;
in {
  options.features.desktop.dracula-theme.enable = mkEnableOption "Theme most apps with dracula theme";

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 14;
      };
      theme = {
        package = pkgs.dracula-theme;
        name = "Dracula";
      };
      iconTheme = {
        package = pkgs.dracula-icon-theme;
        name = "Dracula";
      };
    };

    qt = {
      enable = true;
      style = {
        package = pkgs.dracula-qt5-theme;
        name = "dracula-theme";
      };
    };

    home.file.".config/fcitx5/conf/classicui.conf".text = ''
      UseDarkTheme=True
      UseAccentColor=True
      ForceWaylandDPI=1
      EnableFractionalScale=True
      Font="fira-code 14"
    '';

    programs = {
      kitty.themeFile = "Dracula";

      wofi.style = ''
        window {
          margin: 0px;
          border: 1px solid #bd93f9;
          background-color: #282a36;
        }

        #input {
          margin: 5px;
          border: none;
          color: #f8f8f2;
          background-color: #44475a;
        }

        #inner-box {
          margin: 5px;
          border: none;
          background-color: #282a36;
        }

        #outer-box {
          margin: 5px;
          border: none;
          background-color: #282a36;
        }

        #scroll {
          margin: 0px;
          border: none;
        }

        #text {
          margin: 5px;
          border: none;
          color: #f8f8f2;
        }

        #entry:selected #text {
          font-weight: bold;
        }
      '';

      waybar.style = ''
        @define-color background-darker rgba(30, 31, 41, 230);
        @define-color background #282a36;
        @define-color selection #44475a;
        @define-color foreground #f8f8f2;
        @define-color comment #6272a4;
        @define-color cyan #8be9fd;
        @define-color green #50fa7b;
        @define-color orange #ffb86c;
        @define-color pink #ff79c6;
        @define-color purple #bd93f9;
        @define-color red #ff5555;
        @define-color yellow #f1fa8c;

        * {
            border: none;
            border-radius: 0;
            font-family: FiraCode Nerd Font;
            font-weight: bold;
            font-size: 14px;
            min-height: 0;
        }

        window#waybar {
            background: rgba(21, 18, 27, 0);
            color: #cdd6f4;
        }

        tooltip {
            background: #1e1e2e;
            border-radius: 10px;
            border-width: 2px;
            border-style: solid;
            border-color: #11111b;
        }

        #workspaces button {
            padding: 5px;
            color: #313244;
            margin-right: 5px;
        }

        #workspaces button.active {
            color: #11111b;
            background: #a6e3a1;
            border-radius: 10px;
        }

        #workspaces button.focused {
            color: #a6adc8;
            background: #eba0ac;
            border-radius: 10px;
        }

        #workspaces button.urgent {
            color: #11111b;
            background: #a6e3a1;
            border-radius: 10px;
        }

        #workspaces button:hover {
            background: #11111b;
            color: #cdd6f4;
            border-radius: 10px;
        }

        #custom-language,
        #custom-updates,
        #custom-caffeine,
        #custom-weather,
        #window,
        #clock,
        #battery,
        #pulseaudio,
        #network,
        #workspaces,
        #tray,
        #mpris,
        #cpu,
        #memory,
        #backlight {
            background: #1e1e2e;
            padding: 0px 10px;
            margin: 3px 0px;
            margin-top: 10px;
            border: 1px solid #181825;
        }

        #tray {
            border-radius: 10px;
            margin-right: 10px;
        }

        #mpris {
            border-radius: 10px;
            margin-right: 10px;
        }

        #workspaces {
            background: #1e1e2e;
            border-radius: 10px;
            margin-left: 10px;
            padding-right: 0px;
            padding-left: 5px;
        }

        #custom-caffeine {
            color: #89dceb;
            border-radius: 10px 0px 0px 10px;
            border-right: 0px;
            margin-left: 10px;
        }

        #custom-language {
            color: #f38ba8;
            border-left: 0px;
            border-right: 0px;
        }

        #custom-updates {
            color: #f5c2e7;
            border-left: 0px;
            border-right: 0px;
        }

        #window {
            border-radius: 10px;
            margin-left: 60px;
            margin-right: 60px;
        }

        #clock {
            color: #fab387;
            border-radius: 10px 0px 0px 10px;
            margin-left: 0px;
            border-right: 0px;
        }

        #network {
            color: #f9e2af;
            border-left: 0px;
            border-right: 0px;
        }

        #cpu {
            color: pink;
            border-left: 0px;
            border-right: 0px;
        }

        #memory {
            color: purple;
            border-radius: 0px 0px 0px 10px;
            border-left: 0px;
            border-right: 0px;
        }

        #pulseaudio {
            color: #89b4fa;
            border-radius: 10px 0px 0px 10px;
            border-left: 0px;
            border-right: 0px;
        }

        #pulseaudio.microphone {
            color: #cba6f7;
            border-left: 0px;
            border-right: 0px;
        }

        #battery {
            color: #a6e3a1;
            border-radius: 0 10px 10px 0;
            margin-right: 10px;
            border-left: 0px;
        }

        #custom-weather {
            border-radius: 0px 10px 10px 0px;
            border-right: 0px;
            margin-left: 0px;
        }
      '';
    };
  };
}
