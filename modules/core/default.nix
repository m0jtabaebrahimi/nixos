# Core system configuration
# This module imports all essential configuration that applies to every host

{ config, lib, pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./locale.nix
    ./networking.nix
    ./security.nix
  ];

  # Required paths for Home Manager xdg.portal and SDDM session detection
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
    "/share/wayland-sessions"
  ];
}
