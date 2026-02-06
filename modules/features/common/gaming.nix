{ self, ... }:
{
  flake.nixosModules.gaming = { config, pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraPackages = with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };

    # Essential for Steam, Heroic, and Lutris to handle 32-bit game binaries
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        libvdpau
        pipewire
        libpulseaudio
        libXtst
        libXi
        gtk2
        gdk-pixbuf
      ];
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
      heroic    # For Epic, GOG, and Amazon
      lutris    # For EA, Ubisoft, and community scripts
      bottles   # Helpful for isolated Windows environments
    ];
  };
}
