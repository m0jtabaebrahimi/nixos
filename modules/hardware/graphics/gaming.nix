# Gaming hardware and software configuration
# Enables Steam, GameMode, Gamescope, and 32-bit graphics support

{ config, lib, ... }:

let
  cfg = config.modules.hardware.graphics.gaming;
in

{
  options.modules.hardware.graphics.gaming = {
    enable = lib.mkEnableOption "Gaming support (Steam, GameMode, Gamescope)";

    openFirewallForSteam = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall ports for Steam features (Remote Play, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable 32-bit graphics support (required for most games)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Steam configuration
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = cfg.openFirewallForSteam;
      dedicatedServer.openFirewall = cfg.openFirewallForSteam;
      localNetworkGameTransfers.openFirewall = cfg.openFirewallForSteam;
      gamescopeSession.enable = true;
    };

    # Gamescope compositor for improved gaming performance
    programs.gamescope.enable = true;

    # GameMode for automatic performance optimizations
    programs.gamemode.enable = true;
  };
}
