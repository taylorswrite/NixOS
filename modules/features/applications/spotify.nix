{ inputs, self, ... }:
{
  flake.nixosModules.spotify = { config, lib, pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      (symlinkJoin {
        name = "spotify";
        paths = [ spotify ];
        buildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/spotify \
            --set NIXOS_OZONE_WL 1 \
            --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
        '';
      })
    ];
  };
}
