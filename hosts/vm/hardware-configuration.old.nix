{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ mesa vulkan-loader vulkan-validation-layers vulkan-tools ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4f09f413-703e-4bed-aa92-59345ff2140b";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/84f312af-92b6-4251-b103-202558bc2d22"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.virtualbox.guest.enable = true;
}
