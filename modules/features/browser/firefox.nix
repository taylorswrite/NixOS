{ self, ... }:
{
  flake.nixosModules.firefox = { config, pkgs, ... }: {
    # 1. System Level Configuration
    programs.firefox = {
      enable = true;
      package = pkgs.firefox; # Standard stable package (Fixes the 'cfg' build error)
      
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
        DisplayBookmarksToolbar = "never";
      };
    };

    # 2. Home Manager Configuration
    home-manager.users."${config.my.user}" = {
      programs.firefox = {
        enable = true;
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
          };
        };
      };
    };
  };
}
