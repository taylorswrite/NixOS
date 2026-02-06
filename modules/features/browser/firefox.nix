{ inputs, ... }:
{
  flake.nixosModules.firefox =
    { config, pkgs, ... }:
    let
      # Helper to simplify the path to the .xpi files in the Nix store
      addonPath = pkg: "file://${pkg}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
      addons = inputs.firefox-addons.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      # --- SYSTEM CONFIGURATION ---
      programs.firefox = {
        enable = true;
        languagePacks = [ "en-US" ];

        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never";
          DisplayMenuBar = "never";
          SearchBar = "unified";

          # FORCE ENABLE EXTENSIONS VIA POLICY
          # This bypasses the "Allow this extension" prompt entirely.
          ExtensionSettings = {
            "*".installation_mode = "allowed";

            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              installation_mode = "force_installed";
              install_url = "${addonPath addons.ublock-origin}/uBlock0@raymondhill.net.xpi";
            };
            # Bitwarden
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              installation_mode = "force_installed";
              install_url = "${addonPath addons.bitwarden}/{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi";
            };
            # Dark Reader
            "addon@darkreader.org" = {
              installation_mode = "force_installed";
              install_url = "${addonPath addons.darkreader}/addon@darkreader.org.xpi";
            };
            # Vimium
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
              installation_mode = "force_installed";
              install_url = "${addonPath addons.vimium}/{d7742d87-e61d-4b78-b8a1-b469842139fa}.xpi";
            };
            # Catppuccin Mocha Mauve
            "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = {
              installation_mode = "force_installed";
              install_url = "${addonPath addons.catppuccin-mocha-mauve}/{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}.xpi";
            };
          };
        };
      };

      # --- HOME MANAGER CONFIGURATION ---
      home-manager.users."${config.my.user}" = {
        programs.firefox = {
          enable = true;
          profiles.default = {
            id = 0;
            name = "default";
            isDefault = true;

            # Note: We do NOT list 'extensions' here anymore. 
            # The 'ExtensionSettings' policy above handles the installation.
            
            settings = {
              "browser.startup.homepage" = "about:blank";
              "browser.search.region" = "US";
              "browser.search.isUS" = true;
              "distribution.searchplugins.defaultLocale" = "en-US";
              "general.useragent.locale" = "en-US";
              "gfx.webrender.all" = true;
              "browser.tabs.inTitlebar" = 0;

              # New tab
              "browser.newtabpage.enabled" = false;
              "browser.newtabpage.activity-stream.enabled" = false;
              "browser.newtabpage.activity-stream.telemetry" = false;
              "browser.newtabpage.activity-stream.feeds.topsites" = false;
              "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
              "browser.newtabpage.activity-stream.feeds.snippets" = false;
              "browser.newtabpage.activity-stream.showSponsored" = false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

              "extensions.autoDisableScopes" = 0;
              "extensions.enabledScopes" = 15;
              "extensions.startupScanScopes" = 15;
              "extensions.updates.enabled" = true;
            };
          };
        };
      };
    };
}
