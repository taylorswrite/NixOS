{ self, ... }:
{
  flake.nixosModules.tmux = { config, pkgs, ... }:
    let
      # Helper script to find git root or current directory
      # Accepts an optional path argument ($1) to handle inactive windows correctly
      project-root = pkgs.writeShellScriptBin "project-root" ''
        DIR="''${1:-.}"
        # Try to find git root
        ROOT=$(${pkgs.git}/bin/git -C "$DIR" rev-parse --show-toplevel 2>/dev/null)
        
        # If ROOT is found, use it; otherwise use the original directory
        TARGET="''${ROOT:-$DIR}"
        
        # Output only the base name (e.g., "nixos" instead of "/home/user/nixos")
        ${pkgs.coreutils}/bin/basename "$TARGET"
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
          
          plugins = with pkgs.tmuxPlugins;
          [
            sensible
            yank
            tmux-thumbs
            tmux-fzf
            fzf-tmux-url
            tmux-floax
            tmux-sessionx
            resurrect
    
            continuum
          ];
          extraConfig = ''
            # --- General Settings ---
            set -g default-terminal "tmux-256color"
            set -ag terminal-overrides ",xterm-256color:RGB"
            set -g renumber-windows on
            set -g set-clipboard on
            set -g status-position top
            
            # Disable automatic renaming to prevent shell titles (path) from interfering
            set-option -g allow-rename off
            set-window-option -g automatic-rename off

            # --- Theme: Catppuccin v2 ---
            set -g @catppuccin_flavor 'mocha'
            set -g @catppuccin_window_status_style "rounded"
            
            # Module Text
            # We strictly use #{pane_current_command} to ignore the shell title (#W)
            # We set ALL text variables to ensure the inactive window (default/text) matches the active one.
            set -g @catppuccin_window_default_text " #{pane_current_command} #(${project-root}/bin/project-root \"#{pane_current_path}\")"
            set -g @catppuccin_window_current_text " #{pane_current_command} #(${project-root}/bin/project-root \"#{pane_current_path}\")"
            set -g @catppuccin_window_text " #{pane_current_command} #(${project-root}/bin/project-root \"#{pane_current_path}\")"
            set -g @catppuccin_window_core_text " #{pane_current_command} #(${project-root}/bin/project-root \"#{pane_current_path}\")"
  
            set -g @catppuccin_window_status "icon"
            
            # Ensure the directory module also uses the script if it appears elsewhere
            set -g @catppuccin_directory_text " #(${project-root}/bin/project-root \"#{pane_current_path}\")"
            set -g @catppuccin_host_text " #(whoami)@#h" 

            # Separator & Color Logic
            set -g @catppuccin_status_left_separator  ""
      
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"
            set -g @catppuccin_session_color "#{?client_prefix,#{E:@thm_yellow},#{E:@thm_green}}"

            # [!IMPORTANT] Load Theme FIRST
            run-shell ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux

            # --- Status Bar Construction ---
            set -g status-left "#{E:@catppuccin_status_session} "
            set -g status-right "#{E:@catppuccin_status_host}"
            # #{E:@catppuccin_status_directory} 

            # --- Plugin Config ---
            # Floax
            set -g @floax-width '80%'
            set -g @floax-height '80%'
         
            set -g @floax-border-color 'magenta'
            set -g @floax-text-color 'blue'
            set -g @floax-bind 'p'
            set -g @floax-change-path 'true'

            # SessionX
            set -g @sessionx-bind 'o'
            set -g @sessionx-x-path '~/dotfiles'
      
            set -g @sessionx-custom-paths '/home/taylor/dotfiles'
            set -g @sessionx-bind-zo-new-window 'ctrl-y'
            set -g @sessionx-auto-accept 'off'
            set -g @sessionx-window-height '85%'
            set -g @sessionx-window-width '75%'
            set -g @sessionx-zoxide-mode 'on'
            set -g @sessionx-filter-current 'false'

 
            # Resurrect & Continuum
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-processes 'lazygit lazydocker btop yazi spotify-player-tmux spotify_player cava opencode nvim'
            set -g @continuum-restore 'on'

            # --- Key Bindings ---
            # Session & Client
  
            bind ^X lock-server
            bind ^D detach
            bind ^L refresh-client
            bind s choose-session
            bind S choose-session
            bind : command-prompt
            bind $ command-prompt "rename-session %%"

  
            # Window Management
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

            # Pane Management
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

            # Copy Mode
            bind-key -T copy-mode-vi v send-keys -X begin-selection

            # [!IMPORTANT] OVERRIDES (Must be LAST to win against the theme)
            # Status Bar Background (#1E1E2E - Mocha Base)
            set -g status-style "bg=#1E1E2E"
            
            # Selection Highlight (#B4BEFE - Lavender)
            # Changed from Rosewater to Lavender for better contrast
            set -g mode-style "bg=#B4BEFE,fg=#1E1E2E"
          '';
        };
      };
    };
}
