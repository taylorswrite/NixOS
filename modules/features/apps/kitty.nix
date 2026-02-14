{ self, ... }:
{
  flake.nixosModules.kitty =
    { config, pkgs, ... }:
    {
      home-manager.users."${config.my.user}" = {
        home.packages = [
          pkgs.nerd-fonts.jetbrains-mono
        ];

        programs.kitty = {
          enable = true;
          themeFile = "Catppuccin-Mocha";

          font = {
            name = "JetBrainsMono Nerd Font Mono";
            size = 16;
          };

          settings = {
            confirm_os_window_close = 0;
            background_opacity = "1.00";
            window_padding_width = 0;
            enable_audio_bell = false;
            paste_actions = "quote-urls-at-prompt";
            clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
          };

          shellIntegration.enableFishIntegration = true;
        };
      };
    };
}
