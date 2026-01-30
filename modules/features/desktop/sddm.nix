{ pkgs, ... }:
{
  flake.nixosModules.sddm = { pkgs, ... }: 
  let
    catppuccin-custom = pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      accent = "mauve";
      font  = "Noto Sans";
      fontSize = "9";
    };
  in
  {
    services.xserver.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
      package = pkgs.kdePackages.sddm; 
      theme = "catppuccin-mocha-mauve";
      extraPackages = [
        catppuccin-custom
        pkgs.kdePackages.qt5compat
        pkgs.kdePackages.qtmultimedia
        pkgs.kdePackages.qtsvg
        pkgs.kdePackages.qtvirtualkeyboard
      ];
    };

    environment.systemPackages = [ catppuccin-custom ];
  };
}
