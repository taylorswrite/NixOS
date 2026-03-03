{ ... }:
{
  flake.darwinModules.aerospace = { config, lib, pkgs, ... }: {
    services.aerospace = {
      enable = true;
      
      # Native Nix-darwin AeroSpace settings
      settings = {
        start-at-login = true;
        
        gaps = {
          inner.horizontal = 8;
          inner.vertical =   8;
          outer.left =       0;
          outer.bottom =     0;
          outer.top =        0;
          outer.right =      0;
        };

        mode.main.binding = {
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

          # Move to workspaces
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";

          # Layouts
          alt-f = "layout floating tiling";
          alt-v = "layout h_accordion"; # vertical split
          alt-s = "layout v_accordion"; # horizontal split
        };
      };
    };
  };
}
