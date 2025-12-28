# SSH server configuration
# Enables OpenSSH server with configurable settings

{ config, lib, ... }:

let
  cfg = config.modules.services.ssh;
in

{
  options.modules.services.ssh = {
    enable = lib.mkEnableOption "OpenSSH server";

    passwordAuthentication = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow password authentication";
    };

    permitRootLogin = lib.mkOption {
      type = lib.types.str;
      default = "yes";
      description = "Permit root login (yes/no/prohibit-password)";
    };

    maxAuthTries = lib.mkOption {
      type = lib.types.int;
      default = 6;
      description = "Maximum authentication attempts";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = cfg.passwordAuthentication;
        PermitRootLogin = cfg.permitRootLogin;
        MaxAuthTries = cfg.maxAuthTries;
      };
    };

    # Open SSH port in firewall
    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
