{ config, lib, pkgs, ... }: with lib;
let
  cfg = config.features.desktop.firefox;
  downloadDir = "${config.home.homeDirectory}/downloads";
in {
  options.features.desktop.firefox.enable =
    mkEnableOption "Install and configure firefox";

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles= {
        gunnar = {
          id = 0;
          isDefault = true;
          name = "gunnar";

          search = {
            force = true;
            default = "Brave";
            engines = {        
              "Brave" = {
                urls = [
                {
                  template = "https://search.brave.com/search?";
                  params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }];
                }];
              };
            }; 
          };

          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            bitwarden
            stylus
            tree-style-tab
            dracula-dark-colorscheme
            tampermonkey
            darkreader
          ];

          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            
            "browser.in-content.dark-mode" = true;
            "browser.toolbars.bookmaks.visibility" = "never";
            "browser.startup.couldRestoreSession.count" = 2;
            "browser.startup.page" = 3;
            "browser.tabs.warnOnCloseOtherTabs" = false;
            "browser.startup.homepage" = "https://search.brave.com";
            "browser.newtab.url" = "https://search.brave.com";
            "browser.download.dir" = downloadDir;

            "privacy.resistFingerprinting" = false;
            "privacy.clearHistory.cookiesAndStorage" = false;
            "privacy.clearOnShutdown.cookies" = false;
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
            "privacy.clearSiteData.cookiesAndStorage" = false;

            "services.sync.prefs.sync.privacy.clearOnShutdown.cookies" = false;
            "services.sync.prefs.sync.privacy.clearOnShutdown_v2.cookiesAndStorage" = false;

            "dom.cookieStore.enabled" = true;

            "webgl.disable" = false;

            "layout.css.devPixelsPerPx" = 1.1;
          };

          userChrome = ''
            @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");
            #tabbrowser-tabs { visibility: collapse; }
            #TabsToolbar { visibility: collapse; }
            #titlebar { display: none; }
            #tabbrowser-tabs { visibility: collapse; }
            tab { display: none; }
            #sidebar-header { visibility: collapse; }
          '';
        };
      };
    };
  };
}
