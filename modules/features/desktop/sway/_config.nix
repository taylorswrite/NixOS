{ config, pkgs, ... }:

{
  xdg.configFile."sway/config".text = ''
    # --- Variables ---
    set $mod Mod4
    set $terminal kitty
    set $browser firefox

    # --- Startup Executables ---
    exec mako

    # --- SWAYFX VISUALS ---
    corner_radius 10
    smart_corner_radius on

    # shadows on
    # shadow_blur_radius 20
    # shadow_color #00000070

    # blur on
    # blur_xray off
    # blur_passes 2
    # blur_radius 5

    # --- Global Appearance ---
    font pango:JetBrainsMono Nerd Font Mono 12
    default_border pixel 2
    default_floating_border pixel 2
    gaps inner 10
    gaps outer 0

    # --- Colors ---
    client.focused          #bd93f9 #bd93f9 #f8f8f2 #bd93f9   #bd93f9
    client.focused_inactive #44475a #44475a #f8f8f2 #44475a   #44475a
    client.unfocused        #282a36 #282a36 #f8f8f2 #282a36   #282a36
    client.urgent           #ff5555 #ff5555 #f8f8f2 #ff5555   #ff5555
    client.placeholder      #282a36 #282a36 #f8f8f2 #282a36   #282a36
    client.background       #f8f8f2

    # --- XWayland ---
    xwayland enable

    # --- Output ---
    # Points to the mutable cache file (.png)
    output * bg ~/.cache/sway/current_wallpaper.png fill

    # --- Idle Config ---
    exec swayidle -w \
        timeout 300 'lock-script' \
        timeout 600 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        before-sleep 'lock-script'

    # --- Scratchpad Rules ---
    for_window [app_id="^scratch_.*"] {
        floating enable
        border pixel 2
        resize set 60ppt 60ppt
        move position center
        sticky enable
        move scratchpad
    }
    for_window [class="^scratch_.*"] {
        floating enable
        border pixel 2
        resize set 60ppt 60ppt
        move position center
        sticky enable
        move scratchpad
    }

    # for_window [app_id="scratch_spotify"] {
    #     floating enable
    #     resize set 80ppt 80ppt
    #     move position center
    #     move scratchpad
    # }

    for_window [class="(?i)spotify-qt"] {
        floating enable
        resize set 80ppt 80ppt
        move position center
        move scratchpad
    }

    for_window [app_id="scratch_firefox"] {
        floating enable
        resize set 80ppt 80ppt
        move position center
    }

    # --- Key Bindings ---
    bindsym $mod+Control+r reload
    bindsym $mod+Control+q exec swaynag -t warning -m 'Exit Sway?' -b 'Yes' 'swaymsg exit'

    # Scripts
    bindsym $mod+x exec powermenu-script
    bindsym $mod+Escape exec lock-script

    bindsym $mod+Shift+Space bar mode toggle

    # Launchers
    bindsym $mod+r exec wmenu-run -p "Run:" -f "Monospace 12" -N 222222 -n ffffff -S 005577 -s ffffff
    bindsym $mod+Return exec $terminal
    bindsym $mod+Shift+b exec $browser
    bindsym $mod+Shift+t exec kitty -e tmux a -t main
    bindsym $mod+Shift+o exec obsidian

    # Clipboard
    bindsym $mod+c exec smart-clipboard copy
    bindsym $mod+v exec smart-clipboard paste

    # Focus / Move / Resize
    bindsym $mod+h focus left
    bindsym $mod+l focus right
    bindsym $mod+k focus up
    bindsym $mod+j focus down
    bindsym Mod1+Tab focus next

    bindsym $mod+Shift+h move left
    bindsym $mod+Shift+l move right
    bindsym $mod+Shift+j move down
    bindsym $mod+Shift+k move up

    bindsym $mod+Control+h resize shrink width 20 px or 10 ppt
    bindsym $mod+Control+l resize grow width 20 px or 10 ppt
    bindsym $mod+Control+k resize shrink height 20 px or 10 ppt
    bindsym $mod+Control+j resize grow height 20 px or 10 ppt

    bindsym $mod+Tab layout toggle all
    bindsym $mod+w kill

    # Scratchpad Toggles
    bindsym $mod+Shift+i exec scratchpad-manager "scratch_btop" "kitty --class scratch_btop -e btop"
    bindsym $mod+Shift+Return exec scratchpad-manager "scratch_kitty" "kitty --class scratch_kitty"
    bindsym $mod+Shift+f exec scratchpad-manager "scratch_yazi" "kitty --class scratch_yazi -e yazi"
    bindsym $mod+Shift+p exec scratchpad-manager "scratch_pomodoro" "kitty --class scratch_pomodoro -e pomodoro-tui"
    bindsym $mod+Shift+r exec scratchpad-manager "scratch_blue" "kitty --class scratch_blue -e bluetui"
    bindsym $mod+Shift+e exec scratchpad-manager "scratch_impala" "kitty --class scratch_impala -e impala"
    # bindsym $mod+Shift+s exec scratchpad-manager "scratch_spotify" "kitty --class scratch_spotify -e spotify_player"
    bindsym $mod+Shift+s exec scratchpad-manager "spotify-qt" "env QT_QPA_PLATFORM=xcb spotify-qt"

    # Firefox Toggle
    bindsym $mod+Shift+a exec toggle-firefox

    # Hardware Keys
    bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
    bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
    bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
    bindsym XF86AudioPlay exec playerctl play-pause
    bindsym XF86AudioPrev exec playerctl previous
    bindsym XF86AudioNext exec playerctl next
    bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle
    bindsym XF86MonBrightnessUp exec brightnessctl s 10%+
    bindsym XF86MonBrightnessDown exec brightnessctl s 10%-

    # Workspaces
    bindsym $mod+1 workspace number 1
    bindsym $mod+2 workspace number 2
    bindsym $mod+3 workspace number 3
    bindsym $mod+4 workspace number 4
    bindsym $mod+5 workspace number 5
    bindsym $mod+6 workspace number 6
    bindsym $mod+7 workspace number 7
    bindsym $mod+8 workspace number 8
    bindsym $mod+9 workspace number 9

    bindsym $mod+Shift+1 move container to workspace number 1; workspace number 1
    bindsym $mod+Shift+2 move container to workspace number 2; workspace number 2
    bindsym $mod+Shift+3 move container to workspace number 3; workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4; workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5; workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6; workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7; workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8; workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9; workspace number 9

    # --- Status Bar ---
    bar {
        position bottom
        status_command i3blocks
        mode hide
        hidden_state hide
        modifier none
        colors {
            statusline #f8f8f2
            background #2C407B
            inactive_workspace #2C407B #2C407B #f8f8f2
            focused_workspace  #bd93f9 #bd93f9 #2C407B
        }
    }
  '';
}
