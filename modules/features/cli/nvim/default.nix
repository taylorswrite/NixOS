{ inputs, self, ... }:
{
  flake.nixosModules.nvim =
    { config, pkgs, ... }:
    {

      # Enable Neovim and LazyVim in Home Manager
      home-manager.users."${config.my.user}" =
        { pkgs, ... }:
        {
          imports = [
            inputs.lazyvim.homeManagerModules.default
          ];

          # Add extra plugins
          programs.neovim.plugins = [
            pkgs.vimPlugins.snacks-nvim
          ];

          programs.lazyvim = {
            enable = true;

            # Point to your configuration directory
            # (Renamed to _nvim-config so import-tree ignores it)
            configFiles = ./_nvim-config;

            # LazyVim Extras
            extras = {
              lang = {
                nix.enable = true;
                python.enable = true;
                markdown.enable = true;
                r.enable = true;
                julia.enable = true;
                typst.enable = true;
              };
            };

            # Extra Packages available to Neovim
            extraPackages = with pkgs; [
              # Utility
              ripgrep
              fd
              fzf
              tree-sitter
              ruff

              # NixOS / Lang Servers
              nil
              nixpkgs-fmt
              statix
              nixd
              alejandra
              deadnix

              # Markdown
              markdownlint-cli2
            ];
          };
        };
    };
}
