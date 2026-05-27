{ inputs, lib, ... }:
let
  # --- HOME MANAGER CONFIGURATION (Shared by both NixOS & Darwin) ---
  homeManagerModule = { config, pkgs, ... }: {
    home-manager.users."${config.my.user}" = {
      programs.firefox = {
        enable = true;

        # Prevent Home Manager from trying to install the Linux binary on macOS.
        # You must add "firefox" to your homebrew.casks list in hidan's configuration.
        package = if pkgs.stdenv.isDarwin then null else pkgs.firefox;

        profiles.default = {
          id = 0;
          name = "default";
          isDefault = true;

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

  # --- SYSTEM CONFIGURATION (NixOS Only) ---
  nixosSystemModule = { pkgs, ... }: 
  let
    addonPath = pkg: "file://${pkg}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
    addons = inputs.firefox-addons.packages."${pkgs.stdenv.hostPlatform.system}";
  in {
    programs.firefox = {
      enable = true;
      languagePacks = [ "en-US" ];

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        PasswordManagerEnabled = false;
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

        ExtensionSettings = {
          "*".installation_mode = "allowed";
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "${addonPath addons.ublock-origin}/uBlock0@raymondhill.net.xpi";
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "force_installed";
            install_url = "${addonPath addons.bitwarden}/{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi";
          };
          "addon@darkreader.org" = {
            installation_mode = "force_installed";
            install_url = "${addonPath addons.darkreader}/addon@darkreader.org.xpi";
          };
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
            installation_mode = "force_installed";
            install_url = "${addonPath addons.vimium}/{d7742d87-e61d-4b78-b8a1-b469842139fa}.xpi";
          };
          "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = {
            installation_mode = "force_installed";
            install_url = "${addonPath addons.catppuccin-mocha-mauve}/{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}.xpi";
          };
        };
      };
    };
  };

in
{
  # NixOS gets both the system-level Firefox configuration and the Home Manager user settings
  flake.nixosModules.firefox = {
    imports = [
      nixosSystemModule
      homeManagerModule
    ];
  };

  # Darwin ONLY gets the Home Manager user settings (no system-level 'programs.firefox' to crash evaluation)
  flake.darwinModules.firefox = {
    imports = [
      homeManagerModule
    ];
  };
}
