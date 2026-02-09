{ inputs, self, ... }:
{
  flake.nixosConfigurations.itachi = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ./_hardware-configuration.nix # Nix Generated - Host Specific
      self.nixosModules.common      # Home Manager, Locale, Base Utils
      self.nixosModules.grub        # Grub & EFI
      self.nixosModules.plymouth    # Boot Animation (Silent)
      # self.nixosModules.nvidia      # Nvidia Drivers & Graphics
      self.nixosModules.wifiImpala  # Lightweight IWD + Impala TUI
      self.nixosModules.ssh         # Hardened SSH
      self.nixosModules.tailscale   # VPN
      self.nixosModules.fail2ban    # Security
      self.nixosModules.sddm        # Login Manager
      self.nixosModules.sway        # Main WM
      self.nixosModules.xfce        # Backup Desktop
      self.nixosModules.mako        # Notifications
      self.nixosModules.fish        # Shell Config (Aliases/Init)
      self.nixosModules.starship    # Prompt
      self.nixosModules.kitty       # Kitty
      self.nixosModules.tmux        # Terminal Multiplexer
      self.nixosModules.pomodoro    # CLI Timer
      self.nixosModules.firefox     # Privacy Browser + Vertical Tabs
      self.nixosModules.nvim        # LazyVim
      self.nixosModules.git         # Git + Delta + LazyGit
      self.nixosModules.dev         # Languages (Python, R, Rust) & Tools
      self.nixosModules.docker      # Container Engine
      self.nixosModules.kvm         # VM Engine (Virt-Manager)
      self.nixosModules.direnv      # Auto-load dev environments (.envrc integration)
      self.nixosModules.audio       # Pipewire (Sound) & Audio Group Permissions
      self.nixosModules.video       # OpenGL (Graphics), Webcam & Brightness Permissions
      self.nixosModules.bluetooth   # Bluetooth Hardware & GUI Manager (Blueman)
      self.nixosModules.spotify     # Spotify GUI
      self.nixosModules.zathura     # Added PDF viewer
      self.nixosModules.sops        # Encrypted secrets
      self.nixosModules.wiremix     # Audio manager tui
      # self.nixosModules.gaming      # Gaming system
      self.nixosModules.kmonadThinkpad # Custom Keyboard Layout
      self.nixosModules.performance # Performance mode

      # Machine-specific
      (
        { config, pkgs, ... }:
        {
          networking.hostName = "itachi";
          my.user = "taylor";
          my.githubUser = "taylorswrite";
          my.githubKeyHash = "sha256-NNOL3eS5Sp2vwLNSaq4F+lQfVWdFdpCwI2hS9ZL84Hk=";
          my.performance = "powersave";
          system.stateVersion = "25.11";
          boot.initrd.luks.devices."luks-6109b0b5-580c-41ee-8f9d-331ab4208886".device = "/dev/disk/by-uuid/6109b0b5-580c-41ee-8f9d-331ab4208886";



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
          };
        }
      )
    ];
  };
}
