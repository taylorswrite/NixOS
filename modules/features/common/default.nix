{ inputs, self, ... }:
{
  flake.nixosModules.common = { config, lib, pkgs, ... }: 
  let
    # Fetch keys from GitHub
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
        default = "taylor";
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

      nix = {
        settings = {
          # Deduplicate files to save space
          auto-optimise-store = true;
          # Enable Flakes (Critical)
          experimental-features = [ "nix-command" "flakes" ];
        };
        # Weekly Garbage Collection to keep disk clean
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };

      # Allow unfree packages (Drivers, Codecs, Chrome, etc.)
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        wget
        curl
      ];

      time.timeZone = "America/Los_Angeles";
      i18n.defaultLocale = "en_US.UTF-8";
      
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        
        # Pass inputs/self to all home-manager modules
        extraSpecialArgs = { inherit inputs self; };
        
        users."${config.my.user}" = {
          home.stateVersion = config.system.stateVersion;
        };
      };
    };
  };
}
