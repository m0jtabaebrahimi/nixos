# Bluetooth hardware configuration
# Enables Bluetooth adapter and Blueman device manager

{ config, lib, ... }:

let
  cfg = config.modules.hardware.bluetooth;
in

{
  options.modules.hardware.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support";

    powerOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Power on Bluetooth adapter at boot";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Bluetooth hardware
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.powerOnBoot;
    };

    # Enable Blueman device manager GUI
    services.blueman.enable = true;
  };
}
