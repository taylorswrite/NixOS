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
      uv
      nodejs
      cargo
      
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

      # --- Language Servers ---
      rPackages.languageserver
    ];
  };
}
