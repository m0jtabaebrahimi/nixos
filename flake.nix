{
  description = "Minimal NixOS Hyprland ISO";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations = {
      oldpc-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./iso.nix
          home-manager.nixosModules.home-manager
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix")
        ];
      };
    };
  };
}