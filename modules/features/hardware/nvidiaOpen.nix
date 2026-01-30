{ self, ... }:
{
  flake.nixosModules.nvidiaOpen = { config, pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    boot.kernelParams = [ "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = true; # Use open-source kernel modules
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # OpenGL / Graphics Configuration
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
        egl-wayland
        libglvnd
      ];
    };
  };
}
