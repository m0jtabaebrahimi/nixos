# Nixpkgs overlays
# This module defines package overlays applied to all hosts

{ nur }:

[
  # Nix User Repository (NUR) overlay
  # Provides additional packages like Firefox addons
  nur.overlays.default

  # Custom overlays can be added here
  # Example:
  # (final: prev: {
  #   myCustomPackage = prev.callPackage ./my-package.nix {};
  # })
]
