{ self, ... }:
{
  flake.nixosModules.tmux =
    { config, pkgs, ... }:
    let
      project-root = pkgs.writeShellScriptBin "project-root" ''
        current_path=$(${pkgs.tmux}/bin/tmux display-message -p "#{pane_current_path}")
        git_root=$(${pkgs.git}/bin/git -C "$current_path" rev-parse --show-toplevel 2>/dev/null)

        if [ -n "$git_root" ]; then
          echo "$(basename "$git_root")"
        else
          echo "$(basename "$current_path")"
        fi
      '';
    in
    {
      home-manager.users."${config.my.user}" = {
        programs.tmux = {
          enable = true;
          shortcut = "b";
          baseIndex = 1;
          escapeTime = 0;
          keyMode = "vi";
          mouse = true;

          plugins = with pkgs.tmuxPlugins; [
            sensible
            yank
            tmux-thumbs
            tmux-fzf
            fzf-tmux-url

            {
              plugin = tmux-floax;
              extraConfig = ''
                set -g @floax-width '80%'
                set -g @floax-height '80%'
                set -g @floax-border-color 'magenta'
                set -g @floax-text-color 'blue'
                set -g @floax-bind 'p'
                set -g @floax-change-path 'true'
              '';
            }

            {
              plugin = tmux-sessionx;
              extraConfig = ''
                set -g @sessionx-bind 'o'
                set -g @sessionx-x-path '~/dotfiles'
                set -g @sessionx-custom-paths '/home/taylor/dotfiles'
                set -g @sessionx-bind-zo-new-window 'ctrl-y'
                set -g @sessionx-auto-accept 'off'
                set -g @sessionx-window-height '85%'
                set -g @sessionx-window-width '75%'
                set -g @sessionx-zoxide-mode 'on'
                set -g @sessionx-custom-paths-subdirectories 'false'
                set -g @sessionx-filter-current 'false'
              '';
            }

            {
              plugin = resurrect;
              extraConfig = ''
                set -g @resurrect-strategy-nvim 'session'
                set -g @resurrect-processes 'lazygit lazydocker btop yazi spotify-player-tmux spotify_player cava opencode nvim'
              '';
            }
            {
              plugin = continuum;
              extraConfig = ''
                set -g @continuum-restore 'on'
              '';
            }
          ];

          extraConfig = ''
            # ==========================================
            # 1. TERMINAL & COLOR OVERRIDES
            # ==========================================
            set -g default-terminal "tmux-256color"
            set -ag terminal-overrides ",xterm-256color:RGB"

            # ==========================================
            # 2. CATPPUCCIN v2 CONFIGURATION
            # ==========================================
            set -g @catppuccin_flavor 'mocha'
            set -g @catppuccin_window_status_style "rounded"

            # --- STATUS MODULE SEPARATORS (Restored) ---
            # These apply specifically to the modules on the right (directory, etc.)
            set -g @catppuccin_status_left_separator  ""
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"

            # Window Text
            set -g @catppuccin_window_default_text " #W"
            set -g @catppuccin_window_current_text " #W"
            set -g @catppuccin_window_status "icon"
            set -g @catppuccin_window_core_text " #W"

            # Directory Module Config
            set -g @catppuccin_directory_text " #(${project-root}/bin/project-root)"

            # Load Catppuccin Manually
            run-shell ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux

            # ==========================================
            # 3. STATUS BAR CONSTRUCTION
            # ==========================================
            set -g status-left ""
            set -g status-right "#{E:@catppuccin_status_directory}"

            set -g status-position top

            # ==========================================
            # 4. KEY BINDINGS
            # ==========================================
            set -g renumber-windows on
            set -g set-clipboard on

            bind ^X lock-server
            bind ^D detach
            bind ^L refresh-client
            bind s choose-session
            bind S choose-session
            bind : command-prompt
            bind $ command-prompt "rename-session %%"

            bind ^C new-window -c "$HOME"
            bind c new-window -c "$HOME"
            bind ^A last-window
            bind H previous-window
            bind L next-window
            bind r command-prompt "rename-window %%"
            bind R source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
            bind '"' choose-window
            bind ^W list-windows
            bind w list-windows

            bind -n C-S-Left swap-window -t -1 \; previous-window
            bind -n C-S-Right swap-window -t +1 \; next-window

            bind | split-window -h -c "#{pane_current_path}"
            bind - split-window -v -c "#{pane_current_path}"
            bind v split-window -h -c "#{pane_current_path}"

            bind h select-pane -L
            bind j select-pane -D
            bind k select-pane -U
            bind l select-pane -R

            bind z resize-pane -Z
            bind -r -T prefix , resize-pane -L 20
            bind -r -T prefix . resize-pane -R 20
            bind -r -T prefix _ resize-pane -D 7
            bind -r -T prefix + resize-pane -U 7

            bind P set pane-border-status
            bind x kill-pane
            bind * setw synchronize-panes
            bind K send-keys "clear"\; send-keys "Enter"

            bind-key -T copy-mode-vi v send-keys -X begin-selection
          '';
        };
      };
    };
}
