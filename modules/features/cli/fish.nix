{ self, ... }:
{
  flake.nixosModules.fish = { config, pkgs, ... }: {
    # System-level Fish enablement
    programs.fish.enable = true;

    home-manager.users."${config.my.user}" = {
      programs.fish = {
        enable = true;
        shellAliases = {
          ".." = "cd ..";
          "..." = "cd ../..";
          g = "git";
          
          # Eza aliases
          l  = "eza";
          ls = "eza -lh -g --icons --git --header";
          la = "eza -la -g --icons --git --header";
          lg = "eza -lh -g --icons --git --git-ignore --header";
          lt = "eza --tree --level=2";
        };
        interactiveShellInit = ''
          set -g fish_greeting ""
        '';
      };

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [ "--cmd cd" ];
      };

      programs.eza = {
        enable = true;
        enableFishIntegration = true;
        icons = "auto";
        git = true;
      };
    };
  };
}
