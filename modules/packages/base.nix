# Base system packages
# Essential CLI tools and utilities for all hosts

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Base utilities
    bat
    fzf

    # Networking tools
    networkmanager
    curl
    wget
    tcpdump
    dnsutils
    nethogs
    iftop
    ntopng


    # Archive utilities
    unzip
    unrar

    # System monitoring
    btop

    # Security
    wireshark
  ];

  # Enable wireshark for network analysis
  programs.wireshark.enable = true;

  # Enable dconf for system configuration
  programs.dconf.enable = true;
}
