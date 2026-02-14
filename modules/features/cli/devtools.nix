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
      # Tools
      gcc
      gnumake
      uv
      nodejs
      cargo
      pkg-config
      psmisc
      bat
      
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
    ];
  };
}
