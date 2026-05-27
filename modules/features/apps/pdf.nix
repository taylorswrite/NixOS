{ ... }:
let
  zathuraPkg = pkgs: pkgs.zathura.override {
    plugins = [ pkgs.zathuraPkgs.zathura_pdf_mupdf ];
  };

  # Helper to only include okular on Linux
  maybeOkular = pkgs: if pkgs.stdenv.isLinux then [ pkgs.kdePackages.okular ] else [ ];

  okular = { config, pkgs, lib, ... }: {
    home-manager.users."${config.my.user}" = {
      home.packages = (maybeOkular pkgs) ++ [ (zathuraPkg pkgs) ];
      xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        defaultApplications."application/pdf" = [ "org.kde.okular.desktop" ];
      };
    };
  };

  zathura = { config, pkgs, lib, ... }: {
    home-manager.users."${config.my.user}" = {
      home.packages = (maybeOkular pkgs) ++ [ (zathuraPkg pkgs) ];
      xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        defaultApplications."application/pdf" = [ "org.pwmt.zathura.desktop" ];
      };
    };
  };
in
{
  flake.nixosModules.okular = okular;
  flake.nixosModules.zathura = zathura;
  flake.darwinModules.okular = okular;
  flake.darwinModules.zathura = zathura;
}
