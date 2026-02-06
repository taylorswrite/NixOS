{ pkgs, ... }:

let
  # ========================================================================
  # PYTHON SCRIPTS
  # ========================================================================

  batteryScript = pkgs.writers.writePython3Bin "battery-icon" {
    flakeIgnore = [ "E501" "W293" "E261" ];
  } ''
    import os
    try:
        bat_paths = ["/sys/class/power_supply/BAT0", "/sys/class/power_supply/BAT1"]
        ac_path = "/sys/class/power_supply/AC"
        total_now = 0
        total_full = 0
        for path in bat_paths:
            if os.path.exists(path):
                try:
                    now = int(open(f"{path}/energy_now").read())
                    full = int(open(f"{path}/energy_full").read())
                except FileNotFoundError:
                    try:
                        now = int(open(f"{path}/charge_now").read())
                        full = int(open(f"{path}/charge_full").read())
                    except FileNotFoundError:
                        continue
                total_now += now
                total_full += full

        if total_full == 0:
            print("")
            exit()

        percent = int((total_now / total_full) * 100)
        try:
            ac_online = int(open(f"{ac_path}/online").read())
            is_charging = ac_online == 1
        except Exception:
            is_charging = False

        discharging_icons = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
        charging_icons = ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂄"]
        idx = min(percent // 10, 10)
        icon = charging_icons[idx] if is_charging else discharging_icons[idx]

        if percent < 25:
            print(f'<span foreground="#ff5555">{icon}</span>')
        else:
            print(icon)
    except Exception:
        print("ERR")
  '';

  brightnessScript = pkgs.writers.writePython3Bin "brightness-icon" {
    libraries = [ ];
    flakeIgnore = [ "E501" "W293" "E261" ];
  } ''
    import subprocess
    try:
        cmd = ["${pkgs.brightnessctl}/bin/brightnessctl", "--class", "backlight", "i", "-m"]
        output = subprocess.check_output(cmd, text=True)
        line = output.strip().split("\n")[0]
        percent = 0
        for item in line.split(","):
            if item.endswith("%"):
                percent = int(item.strip("%"))
                break

        if percent < 30:
            print("󰃞")
        elif percent < 100:
            print("󰃟")
        else:
            print("󰃠")
    except Exception:
        print("ERR")
  '';

  volumeScript = pkgs.writers.writePython3Bin "volume-icon" {
    flakeIgnore = [ "E501" "W293" "E261" ];
  } ''
    import subprocess
    try:
        vol_proc = subprocess.run(["${pkgs.pamixer}/bin/pamixer", "--get-volume"], stdout=subprocess.PIPE, text=True)
        mute_proc = subprocess.run(["${pkgs.pamixer}/bin/pamixer", "--get-mute"], stdout=subprocess.PIPE, text=True)

        volume = int(vol_proc.stdout.strip())
        is_muted = mute_proc.stdout.strip() == "true"

        icon_mute = "󰝟"
        icon_low = "󰕿"
        icon_med = "󰖀"
        icon_high = "󰕾"

        if is_muted or volume == 0:
            print(f'<span foreground="#6272a4">{icon_mute}</span>')
        elif volume < 30:
            print(icon_low)
        elif volume < 70:
            print(icon_med)
        else:
            print(icon_high)
    except Exception:
        print("ERR")
  '';

  # ========================================================================
  # BASH SCRIPTS
  # ========================================================================

  # 1. LOCK SCRIPT (Simplified: No battery, no ImageMagick overlay)
  lockScript = pkgs.writeShellScriptBin "lock-script" ''
    PID_FILE="/tmp/swaylock.pid"

    # Check if swaylock is already running
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "swaylock is already running (PID: $PID)"
            exit 0
        else
            # PID file exists but process is dead, remove it
            rm -f "$PID_FILE"
        fi
    fi

    # Create PID file with atomic operation
    (
        exec 200>"$PID_FILE"
        if ${pkgs.flock}/bin/flock -n 200; then
            echo $$ > "$PID_FILE"
        else
            echo "Failed to acquire lock for PID file"
            exit 1
        fi
    ) || exit 1

    # Cleanup function
    cleanup() {
        rm -f "$PID_FILE"
    }

    # Set up trap to cleanup on exit
    trap cleanup EXIT INT TERM

    IMAGE="$HOME/.cache/sway/locked_bg.png"

    # Fallback
    if [ ! -f "$IMAGE" ]; then
        IMAGE="${pkgs.swaylock-effects}/share/pixmaps/swaylock/lock.png"
    fi

    # Use swaylock-effects
    ${pkgs.swaylock-effects}/bin/swaylock -i "$IMAGE" \
      --clock \
      --font-size 60 \
      --indicator \
      --indicator-radius 160 \
      --indicator-thickness 12 \
      --timestr "%H:%M" \
      --datestr ""
  '';
  # 2. WALLPAPER MANAGER
  wallpaperScript = pkgs.writeShellScriptBin "wallpaper-manager" ''
    NEW_WALLPAPER="$1"
    CACHE_DIR="$HOME/.cache/sway"
    CURRENT_BG="$CACHE_DIR/current_wallpaper.png"
    LOCKED_BG="$CACHE_DIR/locked_bg.png"

    if [ -z "$NEW_WALLPAPER" ]; then
      echo "Usage: wallpaper-manager <path-to-image>"
      exit 1
    fi

    mkdir -p "$CACHE_DIR"

    # 1. Overwrite the current wallpaper
    cp "$NEW_WALLPAPER" "$CURRENT_BG"

    # 2. Generate new blurred lock screen
    echo "Generating blurred version..."
    ${pkgs.imagemagick}/bin/magick "$NEW_WALLPAPER" \
      -resize "1920x1080^" -gravity center -extent "1920x1080" -blur 0x15 \
      "$LOCKED_BG"

    # 3. Refresh Sway (Using swayfx binary)
    ${pkgs.swayfx}/bin/swaymsg output "*" bg "$CURRENT_BG" fill
    ${pkgs.libnotify}/bin/notify-send "Wallpaper Updated"
  '';

  # 3. POWER MENU
  powermenuScript = pkgs.writeShellScriptBin "powermenu-script" ''
    WMENU_STYLE="-f 'Monospace 12' -N '#222222' -n '#ffffff' -S '#005577' -s '#ffffff'"
    OPTIONS="Lock\nLogout\nSuspend\nReboot\nShutdown"
    CHOICE=$(echo -e "$OPTIONS" | eval ${pkgs.wmenu}/bin/wmenu -p "Power:" $WMENU_STYLE)

    case "$CHOICE" in
      Lock)     lock-script ;;
      Logout)   ${pkgs.swayfx}/bin/swaymsg exit ;;
      Suspend)  systemctl suspend ;;
      Reboot)   systemctl reboot ;;
      Shutdown) systemctl poweroff ;;
    esac
  '';

  # 4. SCRATCHPAD MANAGER
  scratchpadScript = pkgs.writeShellScriptBin "scratchpad-manager" ''
    target_id="$1"
    cmd="$2"
    focused_id=$(${pkgs.swayfx}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq -r '
        .. | objects | select(.focused == true) | .app_id // .window_properties.class // empty
    ')

    if [ "$focused_id" = "$target_id" ]; then
      ${pkgs.swayfx}/bin/swaymsg "[app_id=\"$target_id\"] move scratchpad" 2>/dev/null ||
        ${pkgs.swayfx}/bin/swaymsg "[class=\"$target_id\"] move scratchpad"
    else
      if ${pkgs.swayfx}/bin/swaymsg -t get_tree | grep -q -E "\"app_id\": \"$target_id\"|\"class\": \"$target_id\""; then
        ${pkgs.swayfx}/bin/swaymsg "[app_id=\"$target_id\"] scratchpad show, resize set width 60ppt height 60ppt, move position center, focus" 2>/dev/null ||
          ${pkgs.swayfx}/bin/swaymsg "[class=\"$target_id\"] scratchpad show, resize set width 60ppt height 60ppt, move position center, focus"
      else
        $cmd &
      fi
    fi
  '';

  # 5. SMART CLIPBOARD
  clipboardScript = pkgs.writeShellScriptBin "smart-clipboard" ''
    focused=$(${pkgs.swayfx}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq -r '.. | select(.type? == "con" and .focused == true) | .app_id // .window_properties.class')
    action=$1
    case "''${focused,,}" in
      *kitty* | *alacritty* | *wezterm* | *foot*) is_terminal=true ;;
      *) is_terminal=false ;;
    esac

    if [ "$is_terminal" = true ]; then
      if [ "$action" == "copy" ]; then
        ${pkgs.wtype}/bin/wtype -M ctrl -M shift -k c -m shift -m ctrl
      else
        ${pkgs.wtype}/bin/wtype -M ctrl -M shift -k v -m shift -m ctrl
      fi
    else
      if [ "$action" == "copy" ]; then
        ${pkgs.wtype}/bin/wtype -M ctrl -k c -m ctrl
      else
        ${pkgs.wtype}/bin/wtype -M ctrl -k v -m ctrl
      fi
    fi
  '';

  # 6. TOGGLE FIREFOX
  firefoxToggleScript = pkgs.writeShellScriptBin "toggle-firefox" ''
    APP_ID="scratch_firefox"
    if ${pkgs.swayfx}/bin/swaymsg -t get_tree | grep -q "\"app_id\": \"$APP_ID\""; then
      ${pkgs.swayfx}/bin/swaymsg "[app_id=\"$APP_ID\"] scratchpad show"
    else
      export MOZ_APP_REMOTINGNAME=$APP_ID
      ${pkgs.firefox}/bin/firefox -P scratchpad --no-remote &
    fi
  '';

  screenshotScript = pkgs.writeShellScriptBin "screenshot-script" ''
    DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$DIR"
    NAME="$DIR/$(date +'%Y-%m-%d_%H-%M-%S.png')"

    if [ "$1" == "area" ]; then
      # Select area, save to file, AND copy to clipboard
      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.coreutils}/bin/tee "$NAME" | ${pkgs.wl-clipboard}/bin/wl-copy
    else
      # Full screen, save to file, AND copy to clipboard
      ${pkgs.grim}/bin/grim - | ${pkgs.coreutils}/bin/tee "$NAME" | ${pkgs.wl-clipboard}/bin/wl-copy
    fi
    
    ${pkgs.libnotify}/bin/notify-send "Screenshot Saved" "Image saved to $NAME"
  '';

in
{
  home.packages = [
    batteryScript
    brightnessScript
    volumeScript
    lockScript
    wallpaperScript
    powermenuScript
    scratchpadScript
    clipboardScript
    firefoxToggleScript
    screenshotScript
  ];
}
