# Nix and Nixpkgs configuration
# Configures Nix daemon settings, experimental features, and package permissions

{ config, lib, ... }:

{
  # Allow unfree packages (required for VS Code, Steam, Chrome, etc.)
  nixpkgs.config.allowUnfree = true;

  # Enable Nix flakes and new CLI
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Optimize storage with automatic garbage collection
  nix.settings.auto-optimise-store = true;

  # Enable trusted users for nix commands
  nix.settings.trusted-users = [ "root" "@wheel" ];
}
