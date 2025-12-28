# Docker virtualization configuration
# Enables rootless Docker with optimized settings

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.hardware.virtualization.docker;
in

{
  options.modules.hardware.virtualization.docker = {
    enable = lib.mkEnableOption "Docker containerization";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      daemon.settings = {
        dns = [ "1.1.1.1" "8.8.8.8" ];
        log-driver = "journald";
        registry-mirrors = [ "https://mirror.gcr.io" ];
        storage-driver = "overlay2";
      };
    };
  };
}
