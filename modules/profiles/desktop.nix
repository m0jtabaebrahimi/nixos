# Desktop profile
# Combines all modules needed for a complete desktop environment

{ ... }:

{
  imports = [
    ../hardware/bluetooth.nix
    ../hardware/audio.nix
    ../packages
  ];

  # Enable hardware for desktop use
  modules.hardware.bluetooth.enable = true;
  modules.hardware.audio.enable = true;
}
