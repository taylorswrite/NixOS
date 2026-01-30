{
  description = "NixOS Configuration using MightyIam/Dendritic Pattern";

  nixConfig = {
    extra-experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    warn-dirty = false;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # Automatically import everything in ./modules
      imports = [ (inputs.import-tree ./modules) ];

      systems = [ "x86_64-linux" ];

      # Pass 'inputs' and 'rootPath' to all modules automatically
      _module.args.rootPath = ./.;
    };
}
