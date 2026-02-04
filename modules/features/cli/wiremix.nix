{ config, lib, pkgs, ... }: {
  # This makes the module available as self.nixosModules.wiremix
  flake.nixosModules.wiremix = { pkgs, config, ... }: {
    environment.systemPackages = [
      pkgs.wiremix
    ];
  };
}
