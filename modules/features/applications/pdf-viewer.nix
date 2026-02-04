{ inputs, self, ... }:
{
  # Flake part for Okular as the default
  flake.nixosModules.okular = { config, pkgs, ... }: {
    home-manager.users."${config.my.user}" = {
      home.packages = [ pkgs.kdePackages.okular pkgs.zathura ];
      xdg.mimeApps = {
        enable = true;
        defaultApplications."application/pdf" = [ "org.kde.okular.desktop" ];
      };
    };
  };

  # Flake part for Zathura as the default
  flake.nixosModules.zathura = { config, pkgs, ... }: {
    home-manager.users."${config.my.user}" = {
      home.packages = [ pkgs.kdePackages.okular pkgs.zathura ];
      xdg.mimeApps = {
        enable = true;
        defaultApplications."application/pdf" = [ "org.pwmt.zathura.desktop" ];
      };
    };
  };
}
