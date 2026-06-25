{ lib, ... }:
let
  remoteBuilderModule = { config, ... }: {
    config = lib.mkIf (config.networking.hostName != "itachi" && config.networking.hostName != "pain") {
      nix.distributedBuilds = true;
      nix.buildMachines = [
        {
          hostName = "itachi";
          system = "x86_64-linux";
          protocol = "ssh-ng";
          maxJobs = 8;
          speedFactor = 2;
          supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
          mandatoryFeatures = [ ];
        }
      ];
      nix.extraOptions = ''
        builders-use-substitutes = true
      '';
    };
  };
in
{
  # Export as modules so your hosts can import them
  flake.nixosModules.remote-builders = remoteBuilderModule;
  flake.darwinModules.remote-builders = remoteBuilderModule;
}
