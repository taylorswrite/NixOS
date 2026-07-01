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
    environment.systemPackages = with pkgs;
    [
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
      cloudflared
      supabase-cli

      # Editor

      # package manager
      pnpm
      corepack
      
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
    ] ++ (if pkgs.stdenv.isLinux then [ 
      psmisc
      rstudio
      vscodium
      zed-editor
    ] else [ ]);

    home-manager.users."${config.my.user}" = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = false;
      };

      programs.fish.interactiveShellInit = ''
        direnv hook fish | source
      '';
    };
  };

  # Extract nix-ld into its own module for NixOS only
  nixosOnlyModule = { pkgs, ... }: {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib # Provides libstdc++.so.6
        zlib
      ];
    };
  };

in
{
  flake.nixosModules.dev = {
    imports = [ sharedModule nixosOnlyModule ];
  };
  flake.darwinModules.dev = sharedModule;
}
