# Helper function to create a NixOS configuration
# This function standardizes host creation with shared modules and consistent structure

{ nixpkgs, home-manager, nur, agenix, inputs }:

let
  system = "x86_64-linux";

  # Shared modules for all hosts
  sharedModules = [
    # Core system configuration
    ../modules/core

    # Hardware modules
    ../modules/hardware/bluetooth.nix
    ../modules/hardware/audio.nix
    ../modules/hardware/graphics/gaming.nix
    ../modules/hardware/virtualization/docker.nix
    ../modules/hardware/virtualization/virtualbox.nix

    # Service modules
    ../modules/services/ssh.nix
    ../modules/services/vpn/pptp.nix
    ../modules/services/proxy.nix
    ../modules/services/ntopng.nix

    # User and secrets modules
    ../modules/users/mojodev.nix
    ../modules/users/secrets.nix
    ../modules/secrets/host-secrets.nix

    # Legacy modules (to be refactored in later phases)
    ../modules/browser-policies.nix
    ../modules/display-manager.nix
    ../modules/agenix.nix

    # External modules
    agenix.nixosModules.default
    home-manager.nixosModules.home-manager

    # Home Manager configuration
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.mojodev = import ../home/mojodev/default.nix;
      nixpkgs.overlays = [ nur.overlays.default ];
    }
  ];

in

# Function signature: mkHost :: String -> [Module] -> NixOSConfiguration
hostName: extraModules:
  nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs agenix; };
    modules = sharedModules ++ [
      ../hosts/${hostName}/default.nix
    ] ++ extraModules;
  }
