{ self, ... }:
{
  flake.nixosModules.git = { config, lib, pkgs, ... }: 
  let
    cfg = config.features.git;
  in
  {
    options.features.git = {
      enable = lib.mkEnableOption "Git, Delta, and LazyGit configuration";
      
      userName = lib.mkOption {
        type = lib.types.str;
        description = "Name to use for git commits";
      };

      userEmail = lib.mkOption {
        type = lib.types.str;
        description = "Email to use for git commits";
      };
    };

    config = lib.mkIf cfg.enable {
      # 1. System Level
      programs.git.enable = true;

      # 2. User Level (Home Manager)
      home-manager.users."${config.my.user}" = {
        programs.git = {
          enable = true;
          
          # FIX: All config now lives under 'settings'
          settings = {
            user = {
              name = cfg.userName;
              email = cfg.userEmail;
            };
            
            init.defaultBranch = "main";
            pull.rebase = true;
            diff.context = 9999;
            merge.conflictstyle = "zdiff3";
          };
        };

        programs.delta = {
          enable = true;
          enableGitIntegration = true; 
          options = {
            navigate = true;
            light = false;
            side-by-side = true;
            line-numbers = true;
          };
        };

        programs.lazygit = {
          enable = true;
          settings = {};
        };
      };
    };
  };
}
