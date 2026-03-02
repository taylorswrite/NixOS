{ ... }: {
  flake.nixosModules.guiApps = { pkgs, config, ... }: {
    home.packages = with pkgs; [
      zoom-us
      obsidian
    ];
  };
}
