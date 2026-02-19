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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # Import everything in ./modules except with a `_` prefix
      imports = [ (inputs.import-tree ./modules) ];
      systems = [
        "x86_64-linux"   # Intel and AMD CPUs
        "aarch64-darwin" # Apple Silicon
        "aarch64-linux"  # Raspberry Pi
      ];
      _module.args.rootPath = ./.;
    };
}
