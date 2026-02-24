{ inputs, ... }:
{
  flake.nixosModules.gaming = { pkgs, ... }:
  let
    pkgsUnstable = import inputs.nixpkgs-unstable {
      system = pkgs.stdenv.hostPlatform.system; # 'system' is generally preferred over 'localSystem' here
      config.allowUnfree = true;
    };
  in
  {
    programs.steam = {
      enable = true;
      package = pkgsUnstable.steam; # Forces Steam to use the unstable package
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = false;
      extraCompatPackages = [ pkgsUnstable.proton-ge-bin ]; # Explicitly use unstable
    };

    # Note: Enable flags use the module from your host's NixOS channel.
    programs.gamemode.enable = true;

    # 32-bit support is required for most Steam games
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Pulls all listed system packages from the unstable channel
    environment.systemPackages = with pkgsUnstable; [
      mangohud
      heroic
      lutris
      bottles
    ];
  };
}
