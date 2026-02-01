{ inputs, self, ... }:
{
  flake.nixosConfigurations.whiteZetsu = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # 1. The Official Installer Module
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

      # 2. Your Custom Modules
      self.nixosModules.common # Home Manager, Locale, Base Utils
      # self.nixosModules.grub        # Grub & EFI
      # self.nixosModules.plymouth    # Boot Animation (Silent)
      # self.nixosModules.nvidiaOpen  # Nvidia Drivers & Graphics
      self.nixosModules.wifiStandard
      # self.nixosModules.wifiImpala  # Lightweight IWD + Impala TUI
      # self.nixosModules.ssh         # Hardened SSH
      # self.nixosModules.tailscale   # VPN
      # self.nixosModules.fail2ban    # Security
      self.nixosModules.sddm # Login Manager
      # self.nixosModules.swayNvidia  # Main WM (Sway + Nvidia Fixes)
      self.nixosModules.xfce # Backup Desktop
      # self.nixosModules.mako        # Notifications
      self.nixosModules.fish # Shell Config (Aliases/Init)
      self.nixosModules.starship # Prompt
      self.nixosModules.kitty # Kitty
      self.nixosModules.tmux # Terminal Multiplexer
      # self.nixosModules.pomodoro    # CLI Timer
      self.nixosModules.firefox # Privacy Browser + Vertical Tabs
      self.nixosModules.nvim # LazyVim
      self.nixosModules.git # Git + Delta + LazyGit
      self.nixosModules.dev # Languages (Python, R, Rust) & Tools
      # self.nixosModules.docker      # Container Engine
      # self.nixosModules.kvm         # VM Engine (Virt-Manager)
      self.nixosModules.direnv # Auto-load dev environments (.envrc integration)
      # self.nixosModules.audio       # Pipewire (Sound) & Audio Group Permissions
      # self.nixosModules.video       # OpenGL (Graphics), Webcam & Brightness Permissions
      self.nixosModules.bluetooth # Bluetooth Hardware & GUI Manager (Blueman)

      # ISO-Specific Configuration
      ({ config, pkgs, lib, ... }: {
        networking.hostName = "whiteZetsu";
        nixpkgs.config.allowUnfree = true;
        hardware.enableAllFirmware = true;
        isoImage.squashfsCompression = "gzip -Xcompression-level 1";
        my.user = "NixOS";
        users.users.root.initialHashedPassword = lib.mkForce "$6$kfftua1sldp8Opg.$/ohgIQzRrOoF1Y1.OCUigMQ8Lk1ef7UOHMyFnL9QYTqIyjLlUWTYo6xFGJu47Pd6Db/R.mkNHtVIw8DDgtmvP/";
        users.users."${config.my.user}".initialHashedPassword = "$6$kfftua1sldp8Opg.$/ohgIQzRrOoF1Y1.OCUigMQ8Lk1ef7UOHMyFnL9QYTqIyjLlUWTYo6xFGJu47Pd6Db/R.mkNHtVIw8DDgtmvP/";
      })
    ];
  };
}
