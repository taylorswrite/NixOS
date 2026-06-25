{ config, pkgs, lib, ... }:
{
  # Only enable on machines that need help building
  config = lib.mkIf (config.networking.hostName != "itachi" && config.networking.hostName != "pain") {
    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        hostName = "itachi"; # Must be resolvable via SSH or /etc/hosts
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
}
