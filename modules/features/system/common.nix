{ inputs, self, ... }:
{
  flake.nixosModules.common = { config, lib, pkgs, ... }: 
  let
    # Fetch public ssh keys from GitHub
    githubKeys = if config.my.githubUser != null then
      pkgs.fetchurl {
        url = "https://github.com/${config.my.githubUser}.keys";
        sha256 = config.my.githubKeyHash;
      }
    else null;
  in
  {
    # 1. Import Home Manager
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    # 2. Define Global Options
    options.my = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Primary user username";
      };

      githubUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "GitHub username to fetch SSH keys from";
      };

      githubKeyHash = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "SHA256 hash of the GitHub keys file";
      };
    };

    config = {
      users.users."${config.my.user}" = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager"];
        openssh.authorizedKeys.keyFiles = 
          lib.optional (githubKeys != null) githubKeys;
      };

      networking.enableIPv6 = true;
      boot.kernel.sysctl = {
        "net.ipv6.conf.all.disable_ipv6" = 0;
        "net.ipv6.conf.default.disable_ipv6" = 0;
      };

      nix = {
        settings = {
          # Deduplicate files to save space
          auto-optimise-store = true;
          # Enable Flakes
          experimental-features = [ "nix-command" "flakes" ];
        };
        # Weekly Garbage Collection
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Basic sys packages
      environment.systemPackages = with pkgs; [
        git
        neovim
        wget
        curl
      ];

      time.timeZone = "America/Los_Angeles";
      i18n.defaultLocale = "en_US.UTF-8";
      
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        
        users."${config.my.user}" = {
          home.stateVersion = config.system.stateVersion;
        };
      };
    };
  };
}
