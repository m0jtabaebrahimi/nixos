# SDDM Display Manager configuration with Niri session
# Provides options for auto-login functionality

{ config, lib, pkgs, ... }:

with lib;

{
  options.modules.displayManager = {
    enable = mkEnableOption "SDDM display manager with Niri";

    autoLogin = {
      enable = mkEnableOption "auto-login for mojodev user";
    };
  };

  config = mkIf config.modules.displayManager.enable {
    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        enableHidpi = true;
      };
      defaultSession = "niri";
      sessionPackages = [ pkgs.niri ];
    } // (optionalAttrs config.modules.displayManager.autoLogin.enable {
      autoLogin = {
        enable = true;
        user = "mojodev";
      };
    });
  };
}
