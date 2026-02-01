# ISO Generation
{ inputs, self, ... }:
{
  # Define the new configuration directly in the flake outputs
  flake.nixosConfigurations.install-iso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      # 1. The Official Installer Module (Live CD Logic)
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

      # 2. Your Custom Modules
      # This gives the USB stick your shell, wifi, keys, and tools!
      self.nixosModules.common
      self.nixosModules.wifi
      self.nixosModules.fish
      self.nixosModules.dev     # (Optional) Makes the ISO larger, but gives you Python/Git
      self.nixosModules.direnv
      # Note: We SKIP 'audio', 'video', 'docker', 'kvm' to keep the ISO smaller/bootable

      # 3. ISO-Specific Configuration
      ({ pkgs, ... }: {
        networking.hostName = "nixos-installer";
        
        # Enable proprietary drivers (Broadcom/Intel WiFi)
        nixpkgs.config.allowUnfree = true;
        hardware.enableAllFirmware = true;

        # Ensure the default 'nixos' user has access to network/sudo
        users.users.nixos.extraGroups = [ "wheel" "networkmanager" ];

        # Speed up the build (Gzip is faster than the default XZ, but makes a slightly larger ISO)
        isoImage.squashfsCompression = "gzip -Xcompression-level 1";
      })
    ];
  };
}
