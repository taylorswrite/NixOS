{ self, ... }:
{
  flake.nixosModules.fish =
    { config, pkgs, ... }:
    {
      # System-level Fish enablement
      programs.fish.enable = true;
      users.users."${config.my.user}".shell = pkgs.fish;

      home-manager.users."${config.my.user}" = {
        programs.fish = {
          enable = true;
          shellAliases = {
            ".." = "cd ..";
            "..." = "cd ../..";
            g = "git";
            gs = "git status";
            ga = "git add";
            gc = "git commit -m";
            gd = "git diff";
            gg = "git checkout";
            gb = "git banch";

            # Eza aliases
            l = "eza";
            ls = "eza -lh -g --icons --git --header";
            la = "eza -la -g --icons --git --header";
            lg = "eza -lh -g --icons --git --git-ignore --header";
            lt = "eza --tree --level=2";
            sedit = "set -x SOPS_AGE_KEY (sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key); sops";
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
