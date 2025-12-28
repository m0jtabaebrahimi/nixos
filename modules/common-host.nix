# Common host configuration shared across all machines
# This module provides base settings that apply to every NixOS host

{ config, lib, pkgs, ... }:

{
  # Allow unfree packages (required for VS Code, Steam, etc.)
  nixpkgs.config.allowUnfree = true;

  # Enable Nix flakes and new CLI
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Locale and timezone defaults
  i18n.defaultLocale = "en_US.UTF-8";

  # Required paths for home-manager xdg.portal and SDDM session detection
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
    "/share/wayland-sessions"
  ];

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;
}
