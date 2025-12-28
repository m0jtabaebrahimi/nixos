# HTTP/SOCKS proxy configuration
# Configures system-wide and session-level proxy settings

{ config, lib, ... }:

let
  cfg = config.modules.services.proxy;
  proxyUrl = "http://${cfg.host}:${toString cfg.port}";
in

{
  options.modules.services.proxy = {
    enable = lib.mkEnableOption "HTTP proxy";

    host = lib.mkOption {
      type = lib.types.str;
      example = "192.0.2.100";
      description = "Proxy server hostname or IP address";
    };

    port = lib.mkOption {
      type = lib.types.port;
      example = 8080;
      description = "Proxy server port";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-level proxy configuration
    networking.proxy.default = proxyUrl;

    # Session-level proxy environment variables
    environment.sessionVariables = {
      ALL_PROXY = proxyUrl;
      HTTP_PROXY = proxyUrl;
      HTTPS_PROXY = proxyUrl;
    };
  };
}
