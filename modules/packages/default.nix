# Common packages configuration
# Imports all package modules for system-wide availability

{ ... }:

{
  imports = [
    ./base.nix
    ./development.nix
    ./desktop.nix
    ./wayland.nix
  ];
}
