{ config, lib, pkgs, modulesPath, ... }:

{
  # Kernel modules for Intel 7th Gen (Kaby Lake) and standard hardware
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Microcode updates for Intel CPUs
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # GPU Configuration for Intel Integrated Graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      virglrenderer
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Power management (often useful for portable/AIO devices)
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
