{ inputs, self, ... }:
{
  flake.nixosConfigurations.pain = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ./_hardware-configuration.nix    # Host Specific
      self.nixosModules.common         # System and Home Manager Config
      self.nixosModules.grub           # Grub & EFI
      self.nixosModules.plymouth       # Boot Animation
      self.nixosModules.nvidia         # Nvidia Drivers & Graphics
      self.nixosModules.wifiImpala     # IWD & Impala TUI
      # self.nixosModules.wifi         # network manager
      self.nixosModules.ssh            # Hardened SSH
      self.nixosModules.tailscale      # VPN Tunnel
      self.nixosModules.fail2ban       # Security
      self.nixosModules.sddm           # Login Manager
      # self.nixosModules.sway         # Main WM
      self.nixosModules.swayNvidia     # Main WM & Nvidia Fixes
      self.nixosModules.xfce           # Backup Desktop
      self.nixosModules.mako           # Notifications
      self.nixosModules.fish           # Shell Config & Aliases
      self.nixosModules.starship       # Pretty Shell Prompt
      self.nixosModules.kitty          # Terminal
      self.nixosModules.tmux           # Terminal Multiplexer
      self.nixosModules.pomodoro       # CLI Pomodoro Timer
      self.nixosModules.firefox        # Browser & configuration
      self.nixosModules.nvim           # LazyVim
      self.nixosModules.git            # Git & tools
      self.nixosModules.dev            # Programing Languages & Tools
      self.nixosModules.docker         # Container Engine
      self.nixosModules.kvm            # VM Engine
      self.nixosModules.direnv         # Auto-load .envrc
      self.nixosModules.audio          # Pipewire
      self.nixosModules.video          # Graphics, Webcam & Brightness
      self.nixosModules.bluetooth      # Bluetooth & Blueman
      self.nixosModules.spotify        # Spotify GUI
      self.nixosModules.zathura        # PDF viewer
      self.nixosModules.sops           # Encrypted secrets
      self.nixosModules.wiremix        # Audio tui
      self.nixosModules.gaming         # Steam & Game Compatibility
      self.nixosModules.kmonadThinkpad # Custom Keyboard Layout
      # self.nixosModules.performance  # CPU Performance modes
      self.nixosModules.mullvad        # VPN service

      # Machine-specific
      (
        { config, pkgs, ... }:
        {
          networking.hostName = "pain";
          my.user = "taylor";
          my.githubUser = "taylorswrite";
          my.githubKeyHash = "0yg0zj9galk84fq90xj5cxaiym7s0np6llmkq2prsjmrwkfqplrl";
          system.stateVersion = "25.11";
          boot.initrd.luks.devices."luks-2195aaa6-86fb-4bae-beb5-788bd215c347".device = "/dev/disk/by-uuid/2195aaa6-86fb-4bae-beb5-788bd215c347";
          boot.resumeDevice = "/dev/mapper/luks-2195aaa6-86fb-4bae-beb5-788bd215c347";

          # Git Identity (Required options for the git module)
          features.git = {
            enable = true;
            userName = "William Martinez";
            userEmail = "wtmartinez@ucla.edu";
          };

          # Host-Specific Aliases
          home-manager.users."${config.my.user}".programs.fish.shellAliases = {
            nixup = "sudo nixos-rebuild switch --flake ~/.nix/#${config.networking.hostName}";
            nixiso = "nix build ~/.nix/#nixosConfigurations.whiteZetsu.config.system.build.isoImage";
            nixsd = "nix build ~/.nix/#nixosConfigurations.blackZetsu.config.system.build.sdImage";
          };
        }
      )
    ];
  };
}
