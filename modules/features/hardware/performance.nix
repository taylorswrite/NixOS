{ inputs, self, ... }:
{
  flake.nixosModules.performance = { lib, config, pkgs, ... }:
  let
    cfg = config.my.features.performance;
  in
  {
    options.my.features.performance = {
      enable = lib.mkEnableOption "System power management profiles";
      profile = lib.mkOption {
        type = lib.types.enum [ "performance" "balanced" "powersave" ];
        default = "balanced";
        description = "Select the system power profile.";
      };
    };

    config = lib.mkIf cfg.enable {
      # Common utilities for all profiles
      environment.systemPackages = [ pkgs.powertop ];
      
      # Profile-specific configurations
      powerManagement.cpuFreqGovernor = lib.mkForce (
        if cfg.profile == "performance" then "performance"
        else if cfg.profile == "balanced" then "schedutil"
        else "powersave"
      );

      services.tlp = {
        enable = true;
        settings = lib.mkIf (cfg.profile == "powersave") {
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          ENERGY_PERF_POLICY_ON_BAT = "power";
        };
      };
    };
  };
}
