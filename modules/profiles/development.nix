# Development workstation profile
# Extends desktop profile with development-specific features

{ ... }:

{
  imports = [
    ./desktop.nix
    ../hardware/virtualization/docker.nix
  ];

  # Enable Docker for development
  modules.hardware.virtualization.docker.enable = true;
}
