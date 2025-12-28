# Networking configuration
# Provides base networking setup for all hosts

{ config, lib, ... }:

{
  # Enable NetworkManager for easy network management
  networking.networkmanager.enable = true;

  # Firewall configuration (permissive by default, can be tightened per-host)
  networking.firewall.enable = true;
}
