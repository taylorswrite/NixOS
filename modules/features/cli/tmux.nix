{ self, ... }:
{
  flake.nixosModules.tmux = { config, pkgs, ... }: {
    
    home-manager.users."${config.my.user}" = {
      programs.tmux = {
        enable = true;

        # --- Basic Settings ---
        shortcut = "b";        # Prefix: Ctrl+b
        baseIndex = 1;         # Start windows at 1 instead of 0
        escapeTime = 0;        # Fix vim mode switching delay
        keyMode = "vi";        # Vim keybindings in copy mode
        mouse = true;          # Enable mouse support

        # --- Plugins ---
        plugins = with pkgs.tmuxPlugins; [
          sensible             # Community standard defaults
          vim-tmux-navigator   # Seamless navigation between vim and tmux panes
          yank                 # Better copying to system clipboard
        ];

        # --- Extra Keybinds ---
        extraConfig = ''
          # Split panes using | and -
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
          unbind '"'
          unbind %

          # Clipboard integration
          set -s set-clipboard on
          set -g @yank_selection_mouse 'clipboard'

          # Reload config with r
          bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
        '';
      };
    };
  };
}
