{ config, pkgs, ... }:
{
  # Common Docker configuration for all hosts
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
}