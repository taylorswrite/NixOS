{ self, ... }:
{
  flake.nixosModules.grub = { pkgs, ... }: {
    boot = {
      loader = {
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          useOSProber = true;
          gfxmodeEfi = "1920x1080";
          gfxpayloadEfi = "keep";
        };
        efi.canTouchEfiVariables = true;
      };
      # Enable emulation for building images for ARM
      binfmt.emulatedSystems = [ "aarch64-linux" ];
    };
  };
}
