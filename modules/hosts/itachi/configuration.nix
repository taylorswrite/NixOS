{ inputs, self, ... }:
{
  flake.nixosConfigurations.pain = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ./_hardware-configuration.nix    # Nix Generated - Host Specific
      self.nixosModules.common         # Home Manager, Locale, Base Utils
      self.nixosModules.grub           # Grub & EFI
      self.nixosModules.plymouth       # Boot Animation (Silent)
      self.nixosModules.nvidiaOpen     # Nvidia Drivers & Graphics
      self.nixosModules.wifiImpala     # Lightweight IWD + Impala TUI
      # self.nixosModules.wifiStandard # Network Manager and iw
      self.nixosModules.ssh            # Hardened SSH
      self.nixosModules.tailscale      # VPN
      self.nixosModules.fail2ban       # Security
      self.nixosModules.sddm           # Login Manager
      self.nixosModules.sway           # Main WM
      # self.nixosModules.swayNvidia   # Main WM + Nvidia Fixes
      self.nixosModules.xfce           # Backup Desktop
      self.nixosModules.mako           # Notifications
      self.nixosModules.fish           # Shell Config (Aliases/Init)
      self.nixosModules.starship       # Prompt
      self.nixosModules.kitty          # Kitty
      self.nixosModules.tmux           # Terminal Multiplexer
      self.nixosModules.pomodoro       # CLI Timer
      self.nixosModules.firefox        # Privacy Browser + Vertical Tabs
      self.nixosModules.nvim           # LazyVim
      self.nixosModules.git            # Git + Delta + LazyGit
      self.nixosModules.dev            # Languages (Python, R, Rust) & Tools
      self.nixosModules.docker         # Container Engine
      self.nixosModules.kvm            # VM Engine (Virt-Manager)
      self.nixosModules.direnv         # Auto-load dev environments (.envrc integration)
      self.nixosModules.audio          # Pipewire (Sound) & Audio Group Permissions
      self.nixosModules.video          # OpenGL (Graphics), Webcam & Brightness Permissions
      self.nixosModules.bluetooth      # Bluetooth Hardware & GUI Manager (Blueman)

      # Machine-specific
      (
        { config, pkgs, ... }:
        {
          networking.hostName = "itachi";
          my.user = "taylor";
          my.githubUser = "taylorswrite";
          my.githubKeyHash = "1hq4ja9zr0fzdmd2nn7bwx5a4kbp06y7kqclbqw7fk5lpab72syi";
          system.stateVersion = "25.11";
          boot.initrd.luks.devices."luks-6109b0b5-580c-41ee-8f9d-331ab4208886".device =>


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
