{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-shell.url = "github:noctalia-dev/noctalia-shell";

    nur.url = "github:nix-community/NUR";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, agenix, ... }@inputs:
    let
      # Import custom library functions
      lib = import ./lib {
        inherit nixpkgs home-manager nur agenix inputs;
        lib = nixpkgs.lib;
      };

    in {
      nixosConfigurations = {
        laptop = lib.mkHost "laptop" [];
        iic-pc = lib.mkHost "iic-pc" [];
        vm = lib.mkHost "vm" [];
      };
    };
}
