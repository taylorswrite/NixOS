{ inputs, self, ... }:
{
  flake.nixosModules.performance = { lib, config, pkgs, ... }:
  let
    # cfg will now directly be the string value (e.g., "powersave")
    cfg = config.my.performance;
  in
  {
    options.my.performance = lib.mkOption {
      type = lib.types.enum [ "performance" "balanced" "powersave" ];
      default = "balanced";
      description = "Select the system power profile directly.";
    };

    config = {
      environment.systemPackages = [ pkgs.powertop ];
      
      powerManagement.cpuFreqGovernor = lib.mkForce (
        if cfg == "performance" then "performance"
        else if cfg == "balanced" then "schedutil"
        else "powersave"
      );

      services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = lib.mkIf (cfg == "performance") "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = lib.mkIf (cfg == "powersave") "powersave";
          ENERGY_PERF_POLICY_ON_BAT = lib.mkIf (cfg == "powersave") "power";
        };
      };
    };
  };
}
