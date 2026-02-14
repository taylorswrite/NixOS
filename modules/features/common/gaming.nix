{ ... }:
{
  flake.nixosModules.gaming = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      # Steam's internal libraries usually handle these; only keep if you have specific compatibility issues
      extraCompatPackages = [ pkgs.protonup-qt ]; 
    };

    # Enable GameMode for better performance
    programs.gamemode.enable = true;

    # 32-bit support is required for most Steam games
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    environment.systemPackages = with pkgs; [
      mangohud
      heroic
      lutris
      bottles
    ];
  };
}
