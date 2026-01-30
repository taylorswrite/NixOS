{ self, ... }:
{
  flake.nixosModules.pomodoro = { config, pkgs, ... }: {
    home-manager.users."${config.my.user}" = {
      home.packages = [
        (pkgs.callPackage ./_package.nix { })
      ];
    };
  };
}
