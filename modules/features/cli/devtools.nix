{ inputs, ... }:
let
  sharedModule = { config, pkgs, lib, ... }: 
  let
    pkgsUnstable = import inputs.nixpkgs-unstable {
      localSystem = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  in
  {
    environment.systemPackages = with pkgs; [
      # Tools
      gcc
      gnumake
      gfortran
      curl
      libuv
      zlib
      openssl
      fontconfig
      freetype
      libxml2
      zip
      unzip
      uv
      ruff
      nodejs
      cargo
      pkg-config
      bat
      btop
      yazi
      devenv
      devbox
      mise

      # Editor
      zed-editor
      rstudio
      vscodium
      
      # Datascience
      python3
      R
      julia-bin
      sqlite

      # Publishing
      quarto
      typst

      # AI Coding
      pkgsUnstable.opencode

      # Language Servers
      rPackages.languageserver
      rPackages.jsonlite
      rPackages.lintr
      markdown-oxide
    ] ++ (if pkgs.stdenv.isLinux then [ psmisc ] else [ ]);

    # Enable nix-ld strictly on Linux to allow dynamically linked PyPI wheels to execute natively
    programs.nix-ld = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib # Provides libstdc++.so.6
        zlib
      ];
    };

    home-manager.users."${config.my.user}" = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        # enableFishIntegration = true;
        # Consider setting silent to false temporarily to debug if it's loading
        silent = false; 
      };

      # Manually force the hook if the integration is being stubborn
      programs.fish.interactiveShellInit = ''
        direnv hook fish | source
      '';
    };
  };
in
{
  flake.nixosModules.dev = sharedModule;
  flake.darwinModules.dev = sharedModule;
}
