{ inputs, self, ... }:
{
  flake.nixosModules.spotify = { config, lib, pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [ 
      spotify 
    ];
  };
}
