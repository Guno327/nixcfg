{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.firefox;

  lock-false = {
    Value = false;
    Status = "locked";
  };

  lock-true = {
    Value = true;
    Status = "locked";
  };
in {
  options.features.desktop.firefox.enable = mkEnableOption "Install and configure firefox";

  config = mkIf cfg.enable {
    stylix.targets.firefox.profileNames = ["gunnar"];
    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          DisableTelemetry = true;
          AllowFileSelectionDialogs = true;
          DisableAccounts = true;
          DisableFirefoxScreenshot = true;
          DisableBookmarksToolsbar = true;
          DontCheckDefaultBrowser = true;
          EnableTrackingProtection = true;

          ExtensionSettings = {
            #"*".installation_mode = "blocked"; # blocks all addons except the ones specified below
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # Privacy Badger:
            "jid1-MnnxcxisBPnSXQ@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
              installation_mode = "force_installed";
            };
            # Bitwarden
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
          };

          # Set preferences shared by all profiles.
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "sidebar.verticalTabs" = lock-true;
          "sidebar.verticalTabs.dragToPinPromo.dismissed" = lock-true;
        };
      };

      profiles = {
        gunnar = {
          id = 0;
          name = "gunnar";
          isDefault = true;
          settings = {
            "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
            "browser.startup.homepage" = "https://search.brave.com/";
            "browser.startup.couldRestoreSession.count" = true;
            "browser.toolbars.bookmarks.visibility" = "never";
          };
          search = {
            default = "brave";
            engines = {
              brave = {
                name = "Brave Search";
                urls = [
                  {
                    template = "https://search.brave.com/search";
                    params = [
                      {
                        name = "source";
                        value = "web";
                      }
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "https://brave.com/favicon.ico";
                definedAliases = ["@b"];
              };
              nix-packages = {
                name = "Nix Packages";
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = ["@np"];
              };
              nix-options = {
                name = "Nix Options";
                urls = [
                  {
                    template = "https://search.nixos.org/options";
                    params = [
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = ["@no"];
              };
              home-manager = {
                name = "Home Manager";
                urls = [
                  {
                    template = "https://home-manager-options.extranix.com";
                    params = [
                      {
                        name = "release";
                        value = "master";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = ["@hm"];
              };
            };
          };
        };
      };
    };
  };
}
