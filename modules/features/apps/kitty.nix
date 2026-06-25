{ self, ... }: 
let
  sharedModule =
    { config, pkgs, ... }:
    {
      home-manager.users."${config.my.user}" = {
        home.packages = [
          pkgs.nerd-fonts.jetbrains-mono
        ];

        programs.kitty = {
          enable = true;
          
          # Use Nix package on Linux, but a dummy package on macOS to avoid Homebrew GUI conflicts
          package = if pkgs.stdenv.isDarwin then pkgs.runCommand "kitty-dummy" {} "mkdir $out" else pkgs.kitty;

          themeFile = "Catppuccin-Mocha";
          font = {
            name = "JetBrainsMono Nerd Font Mono";
            size = 16;
          };

          settings = {
            shell = "${pkgs.fish}/bin/fish";
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
in
{
  flake.nixosModules.kitty = sharedModule;
  flake.darwinModules.kitty = sharedModule;
}
