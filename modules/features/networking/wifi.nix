{ self, ... }:
{
  # ==========================================
  # Option 1: Lightweight IWD + Impala TUI
  # Usage: imports = [ self.nixosModules.wifiImpala ];
  # ==========================================
  flake.nixosModules.wifiImpala = { config, pkgs, lib, ... }: {
    # 1. Force NetworkManager OFF
    # Using mkForce ensures this wins even if another module tries to enable NM
    networking.networkmanager.enable = lib.mkForce false;

    # 2. Enable IWD
    networking.wireless.iwd = {
      enable = true;
      settings = {
        IPv6.Enabled = true;
        General.EnableNetworkConfiguration = true;
      };
    };

    # 3. Install Impala TUI
    environment.systemPackages = [ pkgs.impala ];
  };

  # ==========================================
  # Option 2: Standard NetworkManager
  # Usage: imports = [ self.nixosModules.wifiStandard ];
  # ==========================================
  flake.nixosModules.wifiStandard = { config, pkgs, ... }: {
    networking.networkmanager.enable = true;
    networking.wireless.iwd.enable = false;
  };
}
