# VirtualBox virtualization configuration
# Enables both host and guest additions with clipboard/drag-drop support

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hardware.virtualization.virtualbox;
in

{
  options.modules.hardware.virtualization.virtualbox = {
    enable = lib.mkEnableOption "VirtualBox with host and guest support";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.virtualbox = {
      host = {
        enable = true;
        enableExtensionPack = true;
      };
      guest = {
        enable = true;
        dragAndDrop = true;
        clipboard = true;
      };
    };
  };
}
