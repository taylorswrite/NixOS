{ ... }:
{
  flake.darwinModules.aerospace = { config, lib, pkgs, ... }: {
    services.aerospace = {
      enable = true;
      
      # Native Nix-darwin AeroSpace settings
      settings = {
        after-startup-command = [
          "exec-and-forget open -a \"Kitty\""
          "exec-and-forget open -a \"Visual Studio Code\""
          "exec-and-forget open -a \"Codex\""
          "exec-and-forget open -a \"Firefox\""
          "exec-and-forget open -a \"Obsidian\""
          "exec-and-forget open -a \"Slack\""
          "exec-and-forget open -a \"Messages\""
          "exec-and-forget open -a \"Qobuz\""
        ];

        on-window-detected = [
          { 
            "if".app-id = "net.kovidgoyal.kitty"; 
            run = [ "move-node-to-workspace 1" "layout v_accordion" ]; 
          }
          { 
            "if".app-id = "com.microsoft.VSCode"; 
            run = [ "move-node-to-workspace 1" "layout v_accordion" ]; 
          }
          { 
            "if".app-name-regex-substring = "Codex"; 
            run = [ "move-node-to-workspace 1" "layout v_accordion" ]; 
          }
          { "if".app-id = "org.mozilla.firefox"; run = "move-node-to-workspace 2"; }
          { "if".app-id = "md.obsidian"; run = "move-node-to-workspace 3"; }
          { "if".app-id = "com.tinyspeck.slackmacgap"; run = "move-node-to-workspace 4"; }
          { "if".app-id = "com.apple.MobileSMS"; run = "move-node-to-workspace 5"; }
          { "if".app-name-regex-substring = "Qobuz"; run = "move-node-to-workspace 6"; }
        ];

        gaps = {
          inner.horizontal = 8;
          inner.vertical =   8;
          outer.left =       0;
          outer.bottom =     0;
          outer.top =        0;
          outer.right =      0;
        };

        mode.main.binding = {
          # System Shortcuts
          alt-shift-r = "reload-config";
          alt-shift-w = "close";

          # Focus windows
          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";

          # Move windows
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          # Workspaces
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";
          alt-7 = "workspace 7";
          alt-8 = "workspace 8";
          alt-9 = "workspace 9";
          alt-0 = "workspace 0";

          # Move to workspaces
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
          alt-shift-6 = "move-node-to-workspace 6";
          alt-shift-7 = "move-node-to-workspace 7";
          alt-shift-8 = "move-node-to-workspace 8";
          alt-shift-9 = "move-node-to-workspace 9";
          alt-shift-0 = "move-node-to-workspace 0";

          # Layouts
          alt-f = "layout floating tiling";
          alt-v = "layout h_accordion"; # vertical split
          alt-s = "layout v_accordion"; # horizontal split
        };
      };
    };
  };
}
