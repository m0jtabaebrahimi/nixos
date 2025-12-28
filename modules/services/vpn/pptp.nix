# PPTP VPN service configuration
# Enables PPTP VPN for MikroTik-compatible connections
# Usage: sudo pon iic-vpn / sudo poff iic-vpn

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.vpn.pptp;
in

{
  options.modules.services.vpn.pptp = {
    enable = lib.mkEnableOption "PPTP VPN support";

    connectionName = lib.mkOption {
      type = lib.types.str;
      example = "iic-vpn";
      description = "Name of the PPTP connection (e.g., iic-vpn, iic-vpn-ati)";
    };

    allowPasswordlessSudo = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow user to run VPN commands (pon/poff) without password";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable PPTP daemon
    services.pppd.enable = true;

    # Load required kernel modules for PPTP
    boot.kernelModules = [
      "ppp_generic"
      "ppp_mppe"
      "ppp_deflate"
      "ppp_async"
      "ip_gre"
      "nf_conntrack_pptp"
      "nf_nat_pptp"
    ];

    # Firewall configuration for PPTP
    networking.firewall = {
      allowedTCPPorts = [ 1723 ];  # PPTP port
      extraCommands = ''
        iptables -A INPUT -p gre -j ACCEPT
        iptables -A OUTPUT -p gre -j ACCEPT
      '';
    };

    # PPTP options file
    environment.etc."ppp/options.pptp".text = ''
      lock
      noauth
      nobsdcomp
      nodeflate
      nomppe
      novj
      novjccomp
      defaultroute
      replacedefaultroute
      usepeerdns
      debug
      logfile /var/log/pptp.log
    '';

    # Allow user to run VPN commands without password (for GUI toggle)
    security.sudo.extraRules = lib.mkIf cfg.allowPasswordlessSudo [
      {
        users = [ "mojodev" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/pon";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/poff";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
