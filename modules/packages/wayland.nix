# Wayland and Niri ecosystem packages
# Window manager, status bars, launchers, and Wayland utilities

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Window manager
    niri

    # Status bars and panels
    waybar

    # Application launcher
    wofi

    # Notification daemon
    mako

    # Wayland utilities
    wl-clipboard
    grim
    slurp

    # Screen locker and idle manager
    swaylock
    swayidle
  ];
}
