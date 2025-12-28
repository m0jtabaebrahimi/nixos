# Library functions for NixOS configuration
# This module exports all custom functions used across the configuration

{ nixpkgs, home-manager, nur, agenix, inputs, lib }:

{
  # Host builder function
  mkHost = import ./mkHost.nix { inherit nixpkgs home-manager nur agenix inputs; };

  # Helper utilities
  helpers = import ./helpers.nix { inherit lib; };
}
