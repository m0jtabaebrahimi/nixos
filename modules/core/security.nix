# Security configuration
# Provides base security settings for all hosts

{ config, lib, ... }:

{
  # Passwordless sudo for wheel group
  # This is convenient for development machines; adjust per-host for production
  security.sudo.wheelNeedsPassword = false;

  # Enable polkit for privilege escalation
  security.polkit.enable = true;
}
