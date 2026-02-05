{ self, ... }:
{
  flake.nixosModules.kitty =
    { config, pkgs, ... }:
    {

      # Enable the font at the system level or user level?
      # Usually easier to just add to home.packages for the user.

      home-manager.users."${config.my.user}" = {
        home.packages = [
          pkgs.nerd-fonts.jetbrains-mono
        ];

        programs.kitty = {
          enable = true;

          # Appearance
          themeFile = "Catppuccin-Mocha";

          font = {
            name = "JetBrainsMono Nerd Font Mono";
            size = 13;
          };

          settings = {
            confirm_os_window_close = 0;
            background_opacity = "1.00";
            window_padding_width = 0;
            enable_audio_bell = false;
            paste_actions = "quote-urls-at-prompt";
          };

          # Shell Integration
          shellIntegration.enableFishIntegration = true;
        };
      };
    };
}
