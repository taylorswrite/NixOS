{ lib, ... }:
{
  # Declare the expected types for darwin flake outputs so they can be merged
  options.flake.darwinModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = { };
    description = "Nix-darwin modules exported by the flake.";
  };

  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = { };
    description = "Nix-darwin system configurations exported by the flake.";
  };
}
