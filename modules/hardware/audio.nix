# Audio hardware configuration
# Enables PipeWire audio server with PulseAudio compatibility

{ config, lib, ... }:

let
  cfg = config.modules.hardware.audio;
in

{
  options.modules.hardware.audio = {
    enable = lib.mkEnableOption "Audio support via PipeWire";
  };

  config = lib.mkIf cfg.enable {
    # Enable sound with PipeWire
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
