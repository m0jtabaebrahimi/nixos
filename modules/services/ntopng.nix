{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.ntopng;
in

{
  options.modules.services.ntopng = {
    enable = lib.mkEnableOption "ntopng network traffic monitoring";

    interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = [ "eth0" "wlan0" ];
      description = "Network interfaces to monitor (empty = all interfaces)";
    };

    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "HTTP web interface port";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ntopng = {
      enable = true;
      interfaces = if cfg.interfaces == [] then [] else cfg.interfaces;
      httpPort = cfg.httpPort;
    };

    # Open firewall for web interface
    networking.firewall.allowedTCPPorts = [ cfg.httpPort ];
  };
}
