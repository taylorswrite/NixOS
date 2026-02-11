{ inputs, ... }:
{
  flake.nixosModules.dev = { config, pkgs, ... }: 
  let
    pkgsUnstable = import inputs.nixpkgs-unstable {
      localSystem = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  in
  {
    environment.systemPackages = with pkgs; [
      # --- Toolchains ---
      gcc
      gnumake
      uv
      nodejs
      cargo
      pkg-config
      
      # --- Data Science ---
      python3
      R
      julia-bin
      sqlite

      # --- Scientific Publishing ---
      quarto
      typst

      # --- Editors & CLI Tools ---
      pkgsUnstable.opencode
      psmisc
      bat

      # --- Language Servers ---
      rPackages.languageserver
      rPackages.jsonlite
      rPackages.lintr
    ];
  };
}
