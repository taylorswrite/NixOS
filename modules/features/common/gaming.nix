{ self, ... }:
{
  # 1. Base Gaming Module: For systems without a dedicated GPU (e.g., ThinkPad)
  flake.nixosModules.gaming = { config, pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
      lutris
      bottles
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
