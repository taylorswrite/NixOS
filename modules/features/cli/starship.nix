{ self, ... }:
{
  flake.nixosModules.starship = { config, lib, ... }: {
    home-manager.users."${config.my.user}" = {
      programs.starship = {
        enable = true;
        
        settings = {
          add_newline = false;
          
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };
          
          format = lib.concatStrings [
            "$username"
            "$hostname"
            "$directory"
            "$nix_shell"
            "$git_branch"
            "$git_state"
            "$git_status"
            "$line_break"
            "$character"
          ];

          nix_shell = {
            symbol = "❄️ ";
            format = "[$symbol$name]($style) ";
            style = "bold blue";
          };

          directory = {
            style = "blue";
          };

          git_branch = {
            format = "[$symbol$branch]($style) ";
            style = "group:git";
          };

          git_status = {
            format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
            style = "cyan";
          };
          
          git_state = {
            format = "\([$state( $progress_current/$progress_total)]($style)\) ";
            style = "bright-black";
          };
          
          cmd_duration = {
            format = "[$duration]($style) ";
            style = "yellow";
          };
        };
      };
    };
  };
}
