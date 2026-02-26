{ inputs, self, ... }:
{
  flake.nixosConfigurations.blackZetsu = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
      self.nixosModules.common      # Home Manager, Locale, Base Utils
      # self.nixosModules.wifiImpala # Wifi Tui
      self.nixosModules.wifiStandard
      self.nixosModules.sshPW        # Password SSH
      self.nixosModules.tailscale    # VPN
      self.nixosModules.fail2ban     # Security
      self.nixosModules.mullvad      # VPN service
      # self.nixosModules.sddm         # Login Manager
      # self.nixosModules.sway         # Main WM (Works well on Pi 4/5)
      # self.nixosModules.xfce         # Backup Desktop
      # self.nixosModules.mako         # Notifications
      self.nixosModules.fish         # Shell Config
      self.nixosModules.starship     # Prompt
      self.nixosModules.kitty        # Terminal
      self.nixosModules.tmux         # Multiplexer
      # self.nixosModules.pomodoro     # Timer
      self.nixosModules.git          # Git Identity
      self.nixosModules.dev          # Dev Tools
      self.nixosModules.direnv       # Env integration
      # self.nixosModules.sops         # Secrets
      # self.nixosModules.firefox      # Browser
      self.nixosModules.nvim         # LazyVim
      # self.nixosModules.audio        # Pipewire
      # self.nixosModules.bluetooth    # Blueman
      # self.nixosModules.spotify      # Spotify
      # self.nixosModules.zathura      # PDF
      # self.nixosModules.wiremix      # Audio TUI
      # self.nixosModules.docker     # Docker (Heavy I/O on SD cards, careful)
      # self.nixosModules.kvm        # VM Engine (Not typical for Pi)
      # self.nixosModules.video      # OpenGL config might conflict with Pi hardware overlay
      # self.nixosModules.gaming     # Steam doesn't work on ARM Linux easily
      # self.nixosModules.kmonadThinkpad # ThinkPad specific keyboard layout
      # self.nixosModules.performance # 'powersave' not ideal for Pi, use 'ondemand'

      # Machine-specific Configuration
      ({ config, pkgs, lib, ... }: {
        networking.hostName = "blackZetsu";
        my.user = "taylor";
        # users.users.root.initialHashedPassword = lib.mkForce "$6$kfftua1sldp8Opg.$/ohgIQzRrOoF1Y1.OCUigMQ8Lk1ef7UOHMyFnL9QYTqIyjLlUWTYo6xFGJu47Pd6Db/R.mkNHtVIw8DDgtmvP/";
        # users.users."${config.my.user}".initialHashedPassword = "$6$kfftua1sldp8Opg.$/ohgIQzRrOoF1Y1.OCUigMQ8Lk1ef7UOHMyFnL9QYTqIyjLlUWTYo6xFGJu47Pd6Db/R.mkNHtVIw8DDgtmvP/";
        users.users.root.initialPassword = "changeme";
        users.users."${config.my.user}".initialPassword = "changeme";
        my.githubUser = "taylorswrite";
        my.githubKeyHash = "sha256-NNOL3eS5Sp2vwLNSaq4F+lQfVWdFdpCwI2hS9ZL84Hk=";

        # Pi Specific Boot Config
        boot.loader.grub.enable = false;
        boot.loader.generic-extlinux-compatible.enable = true;
        boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];
        sdImage.compressImage = false;
        boot.initrd.allowMissingModules = true;
        # boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

        # Used only when using virutualisation
        virtualisation.vmVariant = {
          virtualisation.cores = 4;
          virtualisation.memorySize = 4096;
          virtualisation.diskSize = 8192;
        };

        documentation.man.generateCaches = false;
        documentation.enable = false;
        documentation.man.enable = false;
        documentation.nixos.enable = false;

        # Git Identity
        features.git = {
          enable = true;
          userName = "William Martinez";
          userEmail = "wtmartinez@ucla.edu";
        };

        system.stateVersion = "25.11";

        # Update Aliases for the new host
        home-manager.users."${config.my.user}".programs.fish.shellAliases = {
          nixup = "sudo nixos-rebuild switch --flake ~/.nix/#${config.networking.hostName}";
        };
      })
    ];
  };
}
