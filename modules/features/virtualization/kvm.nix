{ self, ... }:
{
  flake.nixosModules.kvm = { config, pkgs, ... }: {
    # 1. Libvirtd Daemon (The Backend)
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true; # TPM support for Windows 11 VMs
      };
    };

    # 2. Virt-Manager (The GUI)
    programs.virt-manager.enable = true;

    # 3. Essential Tools
    environment.systemPackages = with pkgs; [
      qemu
      quickemu      # Easy VM creation helper
      polkit_gnome  # Required for authentication dialogs in Sway
    ];
  };
}
