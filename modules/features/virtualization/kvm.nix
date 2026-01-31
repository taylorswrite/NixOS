{ self, ... }:
{
  flake.nixosModules.kvm =
    { config, pkgs, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true; # TPM support for Windows 11 VMs
        };
      };

      programs.virt-manager.enable = true;

      # 'libvirtd' allows managing VMs without sudo
      # 'kvm' allows accessing /dev/kvm hardware acceleration
      users.users."${config.my.user}".extraGroups = [
        "libvirtd"
        "kvm"
      ];

      environment.systemPackages = with pkgs; [
        qemu
        quickemu # Easy VM creation helper
        polkit_gnome # Required for authentication dialogs in Sway
      ];
    };
}
