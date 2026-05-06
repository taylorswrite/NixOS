{
  description = "NixOS Configuration using MightyIam/Dendritic Pattern";

  nixConfig = {
    extra-experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    warn-dirty = false;
  };

  inputs = {
    # Changed to track the 25.11 stable release branch
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; 
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager = {
      # Must match the nixpkgs stable release branch
      url = "github:nix-community/home-manager/release-25.11"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kmonad = {
      url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
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
