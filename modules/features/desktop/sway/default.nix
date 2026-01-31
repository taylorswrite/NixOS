{ self, ... }:
{
  flake.nixosModules.sway = { config, pkgs, lib, ... }: {
    # System Level Configuration
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      package = pkgs.swayfx;
    };

    # Home Manager Configuration
    home-manager.users."${config.my.user}" = { pkgs, lib, ... }: { 
      
      imports = [
        ./_packages.nix
        ./_scripts.nix
        ./_config.nix
        ./_swaylock.nix
      ];

      home.activation.setupWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
        CACHE_DIR="$HOME/.cache/sway"
        mkdir -p "$CACHE_DIR"

        if [ ! -f "$CACHE_DIR/current_wallpaper.png" ]; then
          echo "Initializing default wallpaper..."
          cp "${./wallpaper.png}" "$CACHE_DIR/current_wallpaper.png"
          chmod 644 "$CACHE_DIR/current_wallpaper.png"

          ${pkgs.imagemagick}/bin/magick "$CACHE_DIR/current_wallpaper.png" \
            -resize "1920x1080^" -gravity center -extent "1920x1080" -blur 0x15 \
            "$CACHE_DIR/locked_bg.png"
        fi
      '';
    };
  };

  flake.nixosModules.swayNvidia = { config, pkgs, ... }: {
    imports = [ self.nixosModules.sway ];

    programs.sway = {
      extraOptions = [ "--unsupported-gpu" ];
      extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
        export NIXOS_OZONE_WL=1
      '';
    };

    services.displayManager.sessionPackages = [
      ((pkgs.writeTextDir "share/wayland-sessions/sway-nvidia.desktop" ''
        [Desktop Entry]
        Name=Sway (Nvidia)
        Comment=Sway with Nvidia Flags Forcefully Applied
        Exec=sway --unsupported-gpu
        Type=Application
      '').overrideAttrs (_: {
        passthru.providedSessions = [ "sway-nvidia" ];
      }))
    ];
  };
}
