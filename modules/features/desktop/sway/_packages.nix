{ pkgs, pkgsUnstable, ... }:

let
  pomodoro-tui = pkgs.callPackage ../../system/pkgs/pomodoro-tui.nix { };
in
{
  home.packages = with pkgs; [
    swayfx
    # pkgsUnstable.spotify-player
    spotify-qt
    bluetui

    # Dependencies
    swaylock-effects
    swayidle
    swaybg
    wmenu
    i3blocks
    wl-clipboard
    playerctl
    brightnessctl
    pulseaudio
    grim
    slurp
    imagemagick
    jq
    wtype
    libnotify
    autotiling

    # Apps
    btop
    yazi
    impala
    kitty
    wdisplays
    zoom-us
    pinta
    mpv
    obsidian
  ];
}
