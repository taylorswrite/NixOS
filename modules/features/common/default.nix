{ inputs, self, ... }:
{
  flake.nixosModules.common = { config, lib, pkgs, ... }: 
  let
    # Logic: Only try to fetch keys if a GitHub user is provided
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
      # 3. Configure User Account
      users.users."${config.my.user}" = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
        
        # Apply the fetched keys if they exist
        openssh.authorizedKeys.keyFiles = 
          lib.optional (githubKeys != null) githubKeys;
      };

      # 4. Configure Home Manager
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        
        # Pass inputs/self to all home-manager modules
        extraSpecialArgs = { inherit inputs self; };
        
        # Initialize state version
        users."${config.my.user}" = {
          home.stateVersion = config.system.stateVersion;
        };
      };
      
      # 5. Common System Settings
      time.timeZone = "America/Los_Angeles";
      i18n.defaultLocale = "en_US.UTF-8";
      
      # Allow unfree packages globally (useful for drivers/codecs)
      nixpkgs.config.allowUnfree = true;
    };
  };
}
